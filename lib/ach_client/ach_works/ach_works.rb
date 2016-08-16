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

        pretty_print_xml true
      end
    end

    # Handles making request to AchWorks.
    # If the request was successful, returns the response
    # If it is unsuccessful, tries to find the error message and raises it in
    # an exception
    # @param method [Symbol] SOAP operation to call against AchWorks
    # @param message [Hash] The request body
    # @param path [Array<Symbol>] Path to the attributes we care about (and the
    # status field) within the response hash. For example, if you have a burrito
    # but only care about the guacomole, the path to the hash with the guac
    # would be: [:aluminum_foil, :tortilla]
    # @return [Hash] The hash the input path led to within the response hash, if
    # the response was successful.
    def self.wrap_request(method:, message:, path:)
      response = self.request(method: method, message: message)
      if response.success?
        response = path.reduce(response.body) {|r, node| r[node] }
        if response[:status] == 'SUCCESS'
          # It worked! Return the response hash
          response
        else
          # AchWorks likes to keep things interesting by sometimes putting
          # the error messages in the details field instead of errors.
          raise response.try(:[], :errors)
                        .try(:[], :string)
                        .try(:join, ', ') ||
                response[:details]
        end
      else
        # This would normally raise an exception on its own, but just in case
        raise "#{method} failed due to unknown SOAP fault"
      end
    end

    # Makes a SOAP request to AchWorks, without any error handling, and returns
    # the savon response
    # @param method [Symbol] SOAP operation to call against AchWorks
    # @param message [Hash] The request body
    # @return [Savon::Response] raw response
    def self.request(method:, message:)
      self.soap_client.call(method, message: message)
    end
  end
end
