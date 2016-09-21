module AchClient
  class Logging
    # Base class for log providers
    # Extending classes must implement send_logs
    # The consumer may implement their own log provider and assign it to
    # AchClient:
    # ```ruby
    # class MyCustomLogger < AchClient::Logging::LogProvider
    #   def self.send_logs(body:, name:)
    #     # Do whatever you want, like send the log data to S3, or whatever
    #     #   logging service you choose
    #   end
    # end
    # AchClient::Logging.log_provider = MyCustomLogger
    # ```
    class LogProvider
      def self.send_logs(body:, name:)
        raise AbstractMethodError, "#{body}#{name}"
      end
    end
  end
end
