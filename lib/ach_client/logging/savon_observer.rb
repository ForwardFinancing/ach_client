module AchClient
  class Logging
    # Hooks into every savon request.
    # #notify is called before the request is made
    class SavonObserver

      ##
      # Hooks into every SOAP request and sends the XML body to be logged.
      # @param operation_name [Symbol] name of SOAP operation being exectuted
      # @param builder [Savon::Builder] Savon wrapper for the request
      # @param globals [Savon::GlobalOptions] Savon's global options
      # @param locals [Savon::LocalOptions] Savon's global options
      # @return [NilClass] returns nothing so the request is not mutated
      def notify(operation_name, builder, globals, _locals)
        # Since Savon only lets us register observers globally this method is called by any other Savon clients outside
        #   this library. We don't want to log for those other clients so we check to see that the request came from
        #   AchClient by comparing the wsdl to our known wsdls
        return unless [
          AchClient::ICheckGateway.wsdl,
          AchClient::AchWorks.wsdl
        ].include?(globals.instance_variable_get(:@options)[:wsdl])
        # Send the xml body to the logger job
        AchClient::Logging::LogProviderJob.perform_async(
          body: builder.to_s,
          name: "request-#{operation_name}-#{DateTime.now}.xml"
        )

        # Must return nil so the request is unaltered
        nil
      end
    end
  end
end
