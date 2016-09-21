module AchClient
  class SiliconValleyBank
    # Class for dealing with SVB's file naming conventions
    class AchFilenameBuilder

      # Connects to the remote server, and finds the next valid filename you
      # can use for upload
      # Starts with "ACHP"
      # Followed by formatted date
      # Followed by "Sequence Number", see below
      # This strategy will be a problem if we are ever sending ACH batches
      # concurrently
      # @return [String] the next filename you should use
      def self.next_file_name
        # ACHP means it is an ACH.
        "ACHP#{file_date}#{sequence_number}"
      end

      private_class_method def self.file_date
        Date.today.strftime('%m%d%y')
      end

      private_class_method def self.sequence_number
        # Pads the sequence number with a leading 0 if necessary
        # Valid values are 00-99, not sure what happens if we exceed that
        (highest_existing_sequence_number_today + 1).to_s.rjust(2, '0')
      end

      private_class_method def self.highest_existing_sequence_number_today
        files_from_today.map do |filename|
          filename[-2..-1].to_i
        end.max || 0
      end

      private_class_method def self.files_from_today
        AchClient::SiliconValleyBank.list_files(
          file_path: AchClient::SiliconValleyBank.outgoing_path,
          glob: "ACHP#{file_date}*"
        )
      end
    end
  end
end
