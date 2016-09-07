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
  end
end
