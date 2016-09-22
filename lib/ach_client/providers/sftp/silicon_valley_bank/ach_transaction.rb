module AchClient
  class SiliconValleyBank
    # SVB representation of a single ACH Transaction
    class AchTransaction < Abstract::AchTransaction

      # SVB only does batch transactions
      # In the future, this could maybe send a batch with this transaction as
      # the single transaction, but due to SVB NACHA file naming convention, we
      # have a limit of 99 transactions per day
      def send
        raise 'SiliconValleyBank does not support individual transactions'
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
        # Not sure what this does yet, suspect is foreign key set by us
        entry.individual_id_number = external_ach_id # Doesn't need to be a number
        entry.individual_name = merchant_name
        entry.originating_dfi_identification =
          AchClient::SiliconValleyBank.originating_dfi_identification
        # Not sure what this does yet, suspect is foreign key set by us
        entry.trace_number = external_ach_id.to_i # Does need to be a number
        entry
      end

      private
      def transaction_code
        [
          AccountTypeTransformer.serialize_to_provider_value(account_type),
          TransactionTypeTransformer.serialize_to_provider_value(
            transaction_type
          )
        ].reduce(&:+)
      end
    end
  end
end
