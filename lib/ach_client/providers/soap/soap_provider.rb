module AchClient
  ## Concern for providers that have SOAP apis, to be included in
  #    provider class
  module SoapProvider
    extend ActiveSupport::Concern

    included do
      # @return [String] Url of provider's WSDL doc for the environment you want
      class_attribute :wsdl

      # @return [Savon::Client] The Savon client object to use for making SOAP
      # requests to the provider
      class_attribute :_soap_client

      # @return [Integer] Number of seconds to leave connections open before
      # raising HTTPClient::ConnectTimeoutError.
      class_attribute :client_timeout_seconds

      # Makes a SOAP request to the provider, without any error handling, and
      # returns the savon response after logging it
      # @param method [Symbol] SOAP operation to call against the provider
      # @param message [Hash] The request body
      # @return [Savon::Response] raw response
      def self.request(method:, message:)
        logged_response(method, soap_client.call(method, message: message))
      end

      private_class_method def self.logged_response(method, response)
        # Provider name can be the name of the class this is included in
        provider_name = self.to_s.demodulize
        AchClient::Logging::LogProviderJob.perform_async(
          body: response.xml,
          name: "response-#{provider_name}-#{method}-#{DateTime.now}.xml"
        )
        response
      end

      # @return [Savon::Client] The Savon client object to use for making SOAP
      # requests to the provider
      private_class_method def self.soap_client
        self._soap_client ||= Savon.client(
          wsdl: self.wsdl,
          open_timeout: self.client_timeout_seconds,
          read_timeout: self.client_timeout_seconds
        ) do
          # Lets us use symbols as keys without Savon changing the case
          # { 'Key' => 'Value' } == { Key: 'Value' }
          convert_request_keys_to :none

          pretty_print_xml true
        end
      end
    end
  end
end
