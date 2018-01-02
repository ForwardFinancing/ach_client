module AchClient
  class Sftp
    # Poll SFTP provider for Inbox files
    class AchStatusChecker < Abstract::AchStatusChecker

      ##
      # Gets the status of ach transactions since the last time we ran this
      # method
      # @return [Hash{String => [AchClient::AchResponse]}] Hash with
      #   individual_id_number values as keys, list of AchResponse objects
      #   as values
      def self.most_recent
        process_files(most_recent_files)
      end

      ##
      # Gets the status of ach transactions between the given dates
      # @param start_date [String] lower bound of date ranged status query
      # @param end_date [String] upper bound of date ranged status query
      # @return [Hash{String => [AchClient::AchResponse]}] Hash with
      #   individual_id_number values as keys, list of AchResponse objects as
      #   values
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
        Helpers::Utils.hashlist_merge(
          (files || []).reduce([]) do |acc, entry|
            ACH::ACHFile.new(entry.last).batches.map do |batch|
              batch.entries.map do |ach|
                # return trace ==> response
                { ach.individual_id_number => [process_ach(batch, ach)] }
              end
            end.reduce([], &:+) + acc
          end
        )
      end

      private_class_method def self.process_ach(batch, ach)
        if ach.addenda.length == 0
          # If there are no addenda, it is a success.
          AchClient::SettledAchResponse.new(
            amount: (ach.amount / 100.0).to_d,
            date: batch.header.effective_entry_date
          )
        else
          # If there is an addenda, it is a return
          process_ach_return(batch, ach)
        end
      end

      private_class_method def self.process_ach_return(batch, ach)
        # I'm not sure why/if there would be multiple addenda.
        # So just taking the first one.
        case ach.addenda.first.reason_code.first
        # If the first letter is R, it is a return
        when 'R'
          AchClient::ReturnedAchResponse.new(
            amount: (ach.amount / 100.0).to_d,
            date: batch.header.effective_entry_date,
            return_code: AchClient::ReturnCodes.find_by(
              code: ach.addenda.first.reason_code
            )
          )
        # If the first letter is C, it is a correction
        when 'C'
          AchClient::CorrectedAchResponse.new(
            amount: (ach.amount / 100.0).to_d,
            date: batch.header.effective_entry_date,
            return_code: AchClient::ReturnCodes.find_by(
              code: ach.addenda.first.reason_code
            ),
            corrections: {
              # The key for deciphering this field is probably documented
              # somewhere. We can expand on this once there is a use case for
              # automatically processing corrections
              unhandled_correction_data: ach.addenda.first.corrected_data
            }
          )
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
          last_modified_time = Time.at(file.attributes.mtime) - 1.minute
          # Filter to files modified in date range
          last_modified_time > start_date && (
            !end_date || last_modified_time < end_date
          ) && file.name != 'most_recent'
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
      rescue Net::SFTP::StatusException => e
        # If code is 2 ("no such file"), then we need to create the file
        #  otherwise, something else went wrong and the exception should
        #  bubble up
        if e.code == 2
          # Create the file and write the current date
          update_most_recent_check_date(connection: connection)
          # Return the earliest possible date as the last check
          Time.at(0).to_datetime
        else
          raise e
        end
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
        files || []
      end
    end
  end
end
