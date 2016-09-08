module AchClient
  class AchWorks

    # AchWorks implementation for AchTransaction
    class AchTransaction < Abstract::AchTransaction

      ##
      # @param super [Array] args from parent class
      # @param ach_id [String] string to use as front_end_trace
      # @param customer_id [String] optional identifier for the customer
      def self.arguments
        super + [:ach_id, :customer_id]
      end

      attr_reader :ach_id,
                  :customer_id

      # Send this transaction individually to AchWorks
      # @return [String] the front end trace
      def send
        AchClient::AchWorks.wrap_request(
          method: :send_ach_trans,
          message: AchClient::AchWorks::InputCompanyInfo.build.to_hash.merge({
            InpACHTransRecord: self.to_hash
          }),
          path: [:send_ach_trans_response, :send_ach_trans_result]
        )[:front_end_trace]
      end

      ##
      # @return [Hash] turns this transaction into a hash that can be sent to
      # AchWorks
      def to_hash
        {
          SSS: AchClient::AchWorks.s_s_s,
          LocID: AchClient::AchWorks.loc_i_d,
          FrontEndTrace: front_end_trace,
          CustomerName: merchant_name,
          CustomerRoutingNo: routing_number.to_s,
          CustomerAcctNo: account_number.to_s,
          OriginatorName: originator_name,
          TransactionCode: sec_code,
          CustTransType:
            AchClient::AchWorks::TransactionTypeTransformer.class_to_string(
              transaction_type
            ),
          CustomerID: customer_id,
          CustomerAcctType:
            AchClient::AchWorks::AccountTypeTransformer.class_to_string(
              self.account_type
            ),
          TransAmount: amount,
          CheckOrTransDate: DateFormatter.format(Date.today), # Does this need to be read from ACH record
          EffectiveDate: DateFormatter.format(Date.today), # Should be same or greater than above (probably same)
          Memo: memo,
          OpCode: 'S', # Check this
          AccountSet: '1'
        }
      end

      # AchWorks Ach needs a "FrontEndTrace", for each ACH transaction.
      # These can be used to track the processing of the ACH after it has been
      # submitted.
      # You can use the id of your Ach record
      # It should be unique per ACH
      # The consumer is responsible for ensuring the uniqueness of this value
      # @return [String] the 12 char front end trace
      def front_end_trace
        # I want to stop this before it goes through because AchWorks might
        # just truncate the value, which could result in lost Achs.
        if ach_id.length > 11
          raise 'AchWorks requires a FrontEndTrace of 12 chars or less'
        else
          # The front end trace MUST NOT start with a W.
          # Our front end trace starts with a Z.
          # The letter Z is not the letter W.
          "Z#{ach_id}"
        end
      end
    end
  end
end
