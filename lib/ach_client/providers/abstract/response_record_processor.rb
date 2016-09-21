module AchClient
  class Abstract
    ## Interface for turning a Provider's response representation of an ACH
    # status into an instance of AchClient::Response
    class ResponseRecordProcessor
      ## Interface for turning a Provider's response representation of an ACH
      # status into an instance of AchClient::Response
      # @param record [Object] the record from the provider
      # @return [AchClient::AchResponse] our representation of the response
      def self.process_response_record(_record)
        raise AbstractMethodError
      end
    end
  end
end
