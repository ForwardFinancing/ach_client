require_relative './savon_observer.rb'
require_relative './log_provider.rb'

module AchClient
  class AchWorks
    # Base class for all things logging
    class Logging

      # Register our observer with Savon
      Savon.observers << AchClient::AchWorks::Logging::SavonObserver.new

      # @return [Class] type of the log provider
      class_attribute :_log_provider_type

      # Defaults to AchClient::AchWorks::Logging::NullLogProvider
      # @return [Class] The Log provider to use.
      def self.log_provider
        self._log_provider_type || AchClient::AchWorks::Logging::NullLogProvider
      end

      # Set the log provider
      # Must extend AchClient::AchWorks::Logging::LogProvider
      # @param [Class] the new log provider
      def self.log_provider=(log_provider)
        if log_provider.is_a?(Class) &&
           log_provider < AchClient::AchWorks::Logging::LogProvider
          self._log_provider_type = log_provider
        else
          raise 'Must be subclass of AchClient::AchWorks::Logging::LogProvider'
        end
      end

      # @return [Array<String>] List of XML nodes to scrub
      class_attribute :_log_filters

      # @return [Array<String>] List of XML nodes to scrub
      def self.log_filters
        self._log_filters || []
      end

      def self.log_filters=(filters)
        self._log_filters = filters
      end
    end
  end
end
