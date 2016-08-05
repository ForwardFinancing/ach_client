require 'active_support/all'
require 'savon'

module AchClient
  # Namespace class for all things AchWorks
  # Contains class attributes with various initialization settings
  class AchWorks

    # @return [String] A key that they give you used as a password
    class_attribute :company_key

    # @return [String] Your user id string, used as a username
    class_attribute :company

    # @return [String] Another Arbitrary 4 letter code AchWorks gives you...
    class_attribute :loc_i_d

    # @return [String] Arbitrary 3 letter code AchWorks gives your company
    class_attribute :s_s_s

    # @return [String] Url of AchWorks WSDL doc for the environment you want
    class_attribute :wsdl

    # @return [Savon::Client] The Savon client object to use for making SOAP
    # requests to AchWorks
    class_attribute :_soap_client

    # @return [Savon::Client] The Savon client object to use for making SOAP
    # requests to AchWorks
    def self.soap_client
      self._soap_client ||= Savon.client(wsdl: self.wsdl) do
        # Lets us use symbols as keys without Savon changing the case
        # { 'Key' => 'Value' } == { Key: 'Value' }
        convert_request_keys_to :none
      end
    end
  end
end
