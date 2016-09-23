module AchClient
  class Logging
    # Worker to asynchronously invoke the log provider
    class LogProviderJob
      include SuckerPunch::Job

      ## Prettifies the xml and sends it asynchronously to the log provider
      # @param xml [String] xml body to log
      # @param name [String] title for the log
      def perform(body:, name:)
        # Savon logger does a nice job of XML pretty print
        # Takes: message, list of filters, pretty print boolean
        AchClient::Logging.log_provider.send_logs(
          body: maybe_encrypt_message(
            message: Savon::LogMessage.new(
              body,
              AchClient::Logging.log_filters,
              true
            ).to_s
          ),
          name: name
        )
      end

      private
      def maybe_encrypt_message(message:)
        # Only encrypt if the client provided a password and a salt
        if AchClient::Logging.should_use_encryption?
          AchClient::Logging.codec.encrypt_and_sign(message)
        else
          message
        end
      end
    end
  end
end
