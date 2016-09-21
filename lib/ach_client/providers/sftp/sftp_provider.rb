module AchClient
  # Base concern for providers like SVB that use an SFTP system instead of API
  module SftpProvider
    extend ActiveSupport::Concern

    included do
      # @return [String] Hostname/URL of SVB's "Direct File Transmission" server
      class_attribute :host

      # @return [String] The username they gave you to login to the server
      class_attribute :username

      # @return [String] The password they gave you to login to the server
      class_attribute :password

      # @return [String] The private ssh key that matches the public ssh key you
      # provided to SVB, ie the output of `cat path/to/private/ssh/key`
      class_attribute :private_ssh_key

      # @return [String] The path on the remote server to the directory where
      # you will deposit your outgoing NACHA files
      class_attribute :outgoing_path

      # Executes the given block with an obtained SFTP connection configured
      # using the above settings
      # @param block [Proc] the code to execute with a provided connection
      # @return [Object] the result of the block
      def self.with_sftp_connection(&_block)
        Net::SFTP.start(
          host,
          username,
          password: password,
          key_data: [private_ssh_key]
        ) do |sftp_connection|
          yield(sftp_connection)
        end
      end

      # Opens an SFTP connection, and writes a new file at the given path with
      # the given body
      # @param file_path [String] path to the new file on the remote server
      # @param file_body [String] text you want to write to the new file
      # @return [String] the filename written to, if successful
      def self.write_remote_file(file_path:, file_body:)
        self.with_sftp_connection do |sftp_connection|
          sftp_connection.file.open!(file_path, 'w') do |file|
            file.puts(file_body)
          end
        end
        file_path
      end

      # Lists the files in the given directory that match the given glob
      # @param file_path [String] path to directory the search will start from
      # @param glob [String] the glob to search for, ie "*.rb" => all .rb files
      # @return [Array<String>] List of discovered filenames that match the glob
      def self.list_files(file_path:, glob:)
        result = nil
        self.with_sftp_connection do |sftp_connection|
          result = sftp_connection.dir.glob(file_path, glob)
        end
        result.map(&:name)
      end
    end
  end
end