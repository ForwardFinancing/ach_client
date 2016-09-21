require 'active_support/all'
require_relative '../soap_provider'

module AchClient
  # Namespace class for all things AchWorks
  # Contains class attributes with various initialization settings
  class AchWorks

    # See concern for functionality shared with other providers that SOAP it up
    include SoapProvider

    # @return [String] A key that they give you used as a password
    class_attribute :company_key

    # @return [String] Your user id string, used as a username
    class_attribute :company

    # @return [String] Another Arbitrary 4 letter code AchWorks gives you...
    class_attribute :loc_i_d

    # @return [String] Arbitrary 3 letter code AchWorks gives your company
    class_attribute :s_s_s

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
  end
end
