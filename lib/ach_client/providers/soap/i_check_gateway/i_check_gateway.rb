module AchClient
  # Wrapper class for all things ICheckGateway
  class ICheckGateway
    include SoapProvider

    # @return [String] Site identifier from ICheckGateway
    class_attribute :site_i_d

    # @return [String] Site key from ICheckGateway
    class_attribute :site_key

    # @return [String] API key from ICheckGateway
    class_attribute :api_key

    # @return [Boolean] ICheckGateway GatewayLiveMode setting
    # ICheckGateway uses their production environment for test/sandbox accounts
    # Set this to false if you don't want your transactions to actually complete
    class_attribute :live

    ## Wraps SOAP request with exception handling and pulls relevent hash out of
    # response
    # @param method [Symbol] SOAP action to call
    # @param message [Hash] SOAP message to send
    # @return [Hash] ICheckGateway response
    def self.wrap_request(method:, message:)
      response = AchClient::ICheckGateway.request(
        method: method,
        message: message
      )
      if response.success?
        response.body["#{method}_response".to_sym]["#{method}_result".to_sym]
      else
        # This happens when something goes wrong within the actual HTTP
        #   request before it gets to the soap processing.
        raise 'Unknown ICheckGateway SOAP fault'
      end
    end
  end
end
