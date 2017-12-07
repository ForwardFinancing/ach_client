module AchClient
  class AchWorks

    # AchWorks implementation for AchTransaction
    class AchTransaction < Abstract::AchTransaction

      # Only allows for merchant length of less than or equal to 22.
      MAX_MERCHANT_NAME_LENGTH = 22.freeze

      ##
      # @param super [Array] args from parent class
      # @param customer_id [String] optional identifier for the customer
      def self.arguments
        super + [:customer_id]
      end

      attr_reader :customer_id

      # Send this transaction individually to AchWorks
      # @return [String] the front end trace
      def do_send
        AchClient::AchWorks.wrap_request(
          method: :send_ach_trans,
          message: AchClient::AchWorks::CompanyInfo.build.to_hash.merge({
            InpACHTransRecord: self.to_hash
          }),
          path: [:send_ach_trans_response, :send_ach_trans_result]
        )[:front_end_trace][1..-1]
      end

      ##
      # @return [Hash] turns this transaction into a hash that can be sent to
      # AchWorks
      def to_hash
        {
          SSS: AchClient::AchWorks.s_s_s,
          LocID: AchClient::AchWorks.loc_i_d,
          FrontEndTrace: front_end_trace,
          CustomerName: merchant_name[0..(MAX_MERCHANT_NAME_LENGTH-1)],
          CustomerRoutingNo: routing_number.to_s,
          CustomerAcctNo: account_number.to_s,
          OriginatorName: originator_name.try(:first, 16),
          TransactionCode: sec_code,
          CustTransType:
            AchClient::AchWorks::TransactionTypeTransformer.serialize_to_provider_value(
              transaction_type
            ),
          CustomerID: customer_id,
          CustomerAcctType:
            AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
              self.account_type
            ),
          TransAmount: amount,
          CheckOrTransDate: DateFormatter.format(effective_entry_date),
          EffectiveDate: DateFormatter.format(effective_entry_date),
          Memo: memo.try(:first, 10),
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
        if external_ach_id.length > 11
          raise 'AchWorks requires a FrontEndTrace of 12 chars or less'
        else
          # The front end trace MUST NOT start with a W.
          # Our front end trace starts with a Z.
          # The letter Z is not the letter W.
          "Z#{external_ach_id}"
        end
      end
    end
  end
end
