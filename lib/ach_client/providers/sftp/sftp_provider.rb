require 'net/sftp'

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

      # @return [String | NilClass] Passphrase for your private ssh key
      # (if applicable)
      class_attribute :passphrase

      # @return [String] The path on the remote server to the directory where
      # you will deposit your outgoing NACHA files
      class_attribute :outgoing_path

      # @return [String] The path on the remote server to the directory where
      # the SFTP provider will deposit return/confirmation files
      class_attribute :incoming_path

      # @return [Proc] A function that defines the filenaming strategy for your
      # provider. The function should take an optional batch number and return
      # a filename string
      class_attribute :file_naming_strategy

      # Executes the given block with an obtained SFTP connection configured
      # using the above settings
      # @param block [Proc] the code to execute with a provided connection
      # @return [Object] the result of the block
      def self.with_sftp_connection(&_block)
        Net::SFTP.start(*connection_params) do |sftp_connection|
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
          sftp_connection.file.open(file_path, 'w') do |file|
            # Log the file contents
            AchClient::Logging::LogProviderJob.perform_async(
              body: file_body,
              name: "request-#{DateTime.now}-#{file_path.parameterize}"
            )
            # Write the file on the remote server
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

      # Returns the contents of the files in the given directory that match
      # the given glob
      # @param file_path [String] path to directory the search will start from
      # @param glob [String] the glob to search for, ie "*.rb" => all .rb files
      # @return [{String => String}] Hash of discovered files, where each
      # key is a filename and each value is a file's contents
      def self.retrieve_files(file_path:, glob:)
        files = nil
        # retrieve the files from the remote server
        self.with_sftp_connection do |sftp_connection|
          files = sftp_connection.dir.glob(file_path, glob).map do |file|
            {
              file.name =>
              sftp_connection.file.open(
                File.join(file_path, file.name),
                'r'
              ).read
            }
          end.reduce(&:merge)
        end
        # log the retrieved files
        files.each do |name, body|
          AchClient::Logging::LogProviderJob.perform_async(
            body: body,
            name: "response-#{DateTime.now}-#{name}"
          )
        end
        files
      end

      private_class_method def self.connection_params
        [
          host,
          username,
          [
            (private_ssh_key ? {key_data: [private_ssh_key]} : nil),
            (passphrase ? {passphrase: passphrase} : nil),
            password: password
          ].compact.reduce(&:merge)
        ]
      end
    end
  end
end
