module AchClient
  class AchWorks
    class Logging
      # Worker to asynchronously invoke the log provider
      class LogProviderJob
        include SuckerPunch::Job

        ## Prettifies the xml and sends it asynchronously to the log provider
        # @param xml [String] xml body to log
        # @param name [String] title for the log
        def perform(xml:, name:)
          # Savon logger does a nice job of XML pretty print
          # Takes: message, list of filters, pretty print boolean
          AchClient::AchWorks::Logging.log_provider.send_logs(
            body: Savon::LogMessage.new(xml, [], true),
            name: name
          )
        end
      end
    end
  end
end
