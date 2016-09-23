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
      def notify(operation_name, builder, _globals, _locals)
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
