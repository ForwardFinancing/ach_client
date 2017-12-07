module AchClient
  class ICheckGateway
    # ICheckGateway implementation for AchTransaction
    class AchTransaction < Abstract::AchTransaction

      # Sends this transaction to ICheckGateway
      # If successful, returns a string from the response that seems to be
      # a unique identifier for the transaction from ICheckGateway
      # Raises an exception with as much info as possible if something goes
      # wrong
      # @return [String] a string returned by ICheckGateway - external_ach_id
      def do_send
        # The response comes back as a | separated list of field values with
        #   no header field/keys. It seems that the first column will contain
        #   'APPROVED' if the request was successful. The 8th column is the
        #   confirmation number
        response = AchClient::ICheckGateway.wrap_request(
          method: :process_check,
          message: self.to_hash
        ).split('|')
        if response[0] == 'APPROVED'
          # Return the confirmation number
          response[7]
        else
          # Don't have a reliable way of getting the error message, so we will
          # just raise the whole response.
          raise "ICheckGateway ACH Transaction Failure: #{response.join('|')}"
        end
      end

      ## Turns this transaction into a Hash that can be sent via soap to the
      # provider
      # @return [Hash] payload for ICheckGateway
      def to_hash
        AchClient::ICheckGateway::CompanyInfo.build.to_hash.merge({
          APIMethod: 'ProcessCheck',
          Amount: amount,
          RoutingNumber: routing_number.to_s,
          AccountNumber: account_number.to_s,
          AccountType: AchClient::ICheckGateway::AccountTypeTransformer
                         .serialize_to_provider_value(account_type),
          EntryClassCode: sec_code,
          TransactionType:
            AchClient::ICheckGateway::TransactionTypeTransformer
              .serialize_to_provider_value(transaction_type),
          CompanyName: merchant_name,
          Description: memo,
          TransactionDate: effective_entry_date
        })
      end
    end
  end
end
