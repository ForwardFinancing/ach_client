require_relative './savon_observer.rb'
require_relative './log_providers/log_provider.rb'

module AchClient
  # Base class for all things logging
  class Logging

    # Register our observer with Savon
    Savon.observers << AchClient::Logging::SavonObserver.new

    # @return [Class] type of the log provider
    class_attribute :_log_provider_type

    # @return [String] password to use for encrypting logs
    class_attribute :encryption_password

    # @return [String] salt to use for encrypting logs
    class_attribute :encryption_salt

    # Defaults to AchClient::Logging::NullLogProvider
    # @return [Class] The Log provider to use.
    def self.log_provider
      self._log_provider_type || AchClient::Logging::NullLogProvider
    end

    # Set the log provider
    # Must extend AchClient::Logging::LogProvider
    # @param [Class] the new log provider
    def self.log_provider=(log_provider)
      if log_provider.is_a?(Class) &&
         log_provider < AchClient::Logging::LogProvider
        self._log_provider_type = log_provider
      else
        raise 'Must be subclass of AchClient::Logging::LogProvider'
      end
    end

    # @return [Array<String>] List of XML nodes to scrub
    class_attribute :_log_filters

    # @return [Array<String>] List of XML nodes to scrub
    def self.log_filters
      self._log_filters || []
    end

    # Updates the log filters
    # @param filters [Array<String>] List of XML nodes to scrub from the logs
    def self.log_filters=(filters)
      self._log_filters = filters
    end

    # Creates a codec (does encryption and decryption) using the provided
    # password and salt
    # @return [ActiveSupport::MessageEncryptor] the encryptor
    def self.codec
      ActiveSupport::MessageEncryptor.new(
        ActiveSupport::KeyGenerator.new(
          AchClient::Logging.encryption_password
        ).generate_key(AchClient::Logging.encryption_salt, 32)
      )
    end

    # Returns whether the client has enabled encryption - if both a username and
    # salt have been provided
    # @return [Boolean] is encryption enabled?
    def self.should_use_encryption?
      encryption_password && encryption_salt
    end

    # Decrypt encrypted log file
    # @param gibberish [String] the log body to decrypt
    def self.decrypt_log(gibberish)
      codec.decrypt_and_verify(gibberish)
    end
  end
end
