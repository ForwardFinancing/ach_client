module AchClient
  class Sftp
    # Generic SFTP provider representation of a single ACH Transaction
    class AchTransaction < Abstract::AchTransaction

      # Most SFTP providers only support batch transactions
      def send
        raise 'NACHA/SFTP providers do not support individual transactions'
      end

      # Converts this ach transaction to the ACH gem's representation of a
      # ach transaction for eventual NACHA transformation
      # @return [ACH::EntryDetail] ACH gem's ach transaction record
      def to_entry_detail
        entry = ACH::EntryDetail.new
        entry.transaction_code = transaction_code
        entry.routing_number = routing_number
        entry.account_number = account_number
        entry.amount = Helpers::DollarsToCents.dollars_to_cents(amount)
        entry.individual_id_number = external_ach_id # Doesn't need to be a number
        entry.individual_name = merchant_name
        entry.originating_dfi_identification =
          self.class.parent.originating_dfi_identification
        entry.trace_number = external_ach_id.gsub(/\D/, '').to_i # Does need to be a number
        entry
      end

      private
      def transaction_code
        [
          AccountTypeTransformer.serialize_to_provider_value(
            account_type
          ),
          TransactionTypeTransformer.serialize_to_provider_value(
            transaction_type
          )
        ].reduce(&:+)
      end
    end
  end
end
