module AchClient
  class ICheckGateway
    # ICheckGateway implementation for AchTransaction
    class AchTransaction < Abstract::AchTransaction

      # Sends this transaction to ICheckGateway
      # If successful, returns a string from the response that might maybe be
      # a unique identifier for the transaction from ICheckGateway, but idk #
      # because it's not documented at all.
      # Raises an exception with as much info as possible if something goes
      # wrong
      # @return [String] a string returned by ICheckGateway
      def send
        response = AchClient::ICheckGateway.request(
          method: :process_check,
          message: self.to_hash
        )
        if response.success?
          # The response comes back as a | separated list of field values with
          #   no keys. There is no documentation around what each column means,
          #   but it seems that the first column will contain 'APPROVED' if the
          #   request was successful. The 8th column seems to be a unique id.
          response = response.body[:process_check_response][
            :process_check_result
          ].split('|')
          if response[0] == 'APPROVED'
            # Return the possible unique ID, which is possibly useful - at a
            #   minimum it can be used in the title of the log file.
            response[7]
          else
            # Don't have a reliable way of getting the error message, so we will
            # just raise the whole response.
            raise "ICheckGateway ACH Transaction Failure: #{response.join('|')}"
          end
        else
          # This happens when something goes wrong within the actual HTTP
          #   request before it gets to the soap processing.
          raise 'Unknown ICheckGateway SOAP fault'
        end
      end

      ## Turns this transaction into a Hash that can be sent via soap to the
      # provider
      # @return [Hash] payload for ICheckGateway
      def to_hash
        {
          APIMethod: 'ProcessCheck',
          SiteID: AchClient::ICheckGateway.site_i_d,
          SiteKey: AchClient::ICheckGateway.site_key,
          APIKey: AchClient::ICheckGateway.api_key,
          Amount: amount,
          RoutingNumber: routing_number.to_s,
          AccountNumber: account_number.to_s,
          AccountType: AchClient::ICheckGateway::AccountTypeTransformer
                         .class_to_string(account_type),
          EntryClassCode: sec_code,
          GatewayLiveMode: AchClient::ICheckGateway.live ? '1' : '0',
          TransactionType:
            AchClient::ICheckGateway::TransactionTypeTransformer
              .class_to_string(transaction_type),
          CompanyName: merchant_name,
          Description: memo,
          TransactionDate: Date.today
        }
      end
    end
  end
end
