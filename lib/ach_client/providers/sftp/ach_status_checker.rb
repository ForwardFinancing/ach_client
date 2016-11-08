module AchClient
  class Sftp
    # Poll SFTP provider for Inbox files
    class AchStatusChecker < Abstract::AchStatusChecker

      ##
      # Gets the status of ach transactions since the last time we ran this
      # method
      # @return [Hash{String => AchClient::AchResponse}] Hash with
      #   individual_id_number values as keys, AchResponse objects as values
      def self.most_recent
        process_files(most_recent_files)
      end

      ##
      # Gets the status of ach transactions between the given dates
      # @param start_date [String] lower bound of date ranged status query
      # @param end_date [String] upper bound of date ranged status query
      # @return [Hash{String => AchClient::AchResponse}] Hash with
      #   individual_id_number values as keys, AchResponse objects as values
      def self.in_range(start_date:, end_date:)
        in_range = {}
        self.parent.with_sftp_connection do |connection|
          in_range = process_files(
            files_in_range(
              connection: connection,
              start_date: start_date,
              end_date: end_date
            )
          )
        end
        in_range
      end

      private_class_method def self.process_files(files)
        files.reduce({}) do |acc, entry|
          ACH::ACHFile.new(entry.last).batches.map do |batch|
            batch.entries.map do |ach|
              # return trace ==> response
              {
                ach.individual_id_number =>
                  if ach.addenda.length == 0
                    # If there are no addenda, I think it is a success.
                    AchClient::SettledAchResponse.new(
                      date: batch.header.effective_entry_date
                    )
                  else
                    # If there are addenda, I think it is a return/correction
                    # But we don't know what those look like yet
                  end
              }
            end.reduce({}, &:merge)
          end.reduce({}, &:merge).merge(acc)
        end
      end

      private_class_method def self.inbox_path_to(filename)
        "#{self.parent.incoming_path}/#{filename}"
      end

      private_class_method def self.files_in_range(
        connection:,
        start_date:,
        end_date: nil
      )
        # Get info on all files - equivalent to `ls`
        connection.dir.entries(self.parent.incoming_path)
                      .select do |file|
          last_modified_time = Time.at(file.attributes.mtime)
          # Filter to files modified in date range
          last_modified_time > start_date && (
            !end_date || last_modified_time < end_date
          )
        end.map do |file|
          body = connection.file.open(inbox_path_to(file.name), 'r').read
          AchClient::Logging::LogProviderJob.perform_async(
            body: body,
            name: "response-#{DateTime.now}-#{file.name.parameterize}"
          )
          { file.name => body }
        end.reduce(&:merge)
      end

      # Returns the last datetime that the most_recent function was called
      private_class_method def self.last_most_recent_check_date(connection:)
        most_recent_string = connection.file.open(
          inbox_path_to('most_recent'),
          'r'
        ).read
        DateTime.parse(most_recent_string)
      end

      # Leave file with last grabbed date
      private_class_method def self.update_most_recent_check_date(connection:)
        connection.file.open(inbox_path_to('most_recent'), 'w') do |file|
          file.write(DateTime.now.to_s)
        end
      end

      private_class_method def self.most_recent_files
        files = []
        self.parent.with_sftp_connection do |connection|
          files = files_in_range(
            connection: connection,
            start_date: last_most_recent_check_date(connection: connection)
          )
        update_most_recent_check_date(connection: connection)
        end
        files
      end
    end
  end
end
