module AchClient
  class ICheckGateway
    # ICheckGateway implementation for AchTransaction
    class AchTransaction < Abstract::AchTransaction

      # When ICheck API gives us an error response containing a correction, the response field looks like this:
      #   DECLINED - Notice of Change (XXX - Change Data: YYYYYY)
      #     Where X is a three character string representing the return code (example: C01)
      #     Where Y is any number of digits representing the updated information for the correction - the
      #       ACH attribute that should be updated (example: 123456789)
      # The (\w{3}) capture group matches the return code, while the (\d+) capture group matches the correction data
      #   for later use.
      NOC_RESPONSE_MATCHER = /DECLINED - Notice of Change \((\w{3}) - Change Data: (\d+)\)/

      # Sends this transaction to ICheckGateway
      # If successful, returns a string from the response that seems to be
      # a unique identifier for the transaction from ICheckGateway
      # Raises an exception with as much info as possible if something goes
      # wrong.
      # ICheck sometimes returns an API error for certain rejection scenarios. In this case we raise a
      #   InstantRejectionError which can be caught to handle any business logic appropriate for this edge case.
      #   The exception contains a method ach_response that returns the information about the return.
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
        elsif response[0].include?('DECLINED - Notice of Change')
          return_code, addendum = NOC_RESPONSE_MATCHER.match(response[0]).captures
          # The API error message incorrectly uses the normal correction return codes when the internal correction
          #  return codes should be used instead (since the transaction is never forwarded through to the NACHA system)
          # Correcting this involves replacing `C0` with `XZ` (ie C01 becomes XZ1)
          corrected_return_code = "XZ#{return_code.last}"
          raise ICheckGateway::InstantRejectionError.new(
            nacha_return_code: corrected_return_code,
            addendum: addendum,
            transaction: self
          ), response[0]
        elsif response[0].include?('DECLINED - Invalid Routing Number')
          raise ICheckGateway::InstantRejectionError.new(nacha_return_code: 'X13', transaction: self), response[0]
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
