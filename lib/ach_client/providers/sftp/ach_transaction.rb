module AchClient
  class Sftp
    # Generic SFTP provider representation of a single ACH Transaction
    class AchTransaction < Abstract::AchTransaction

      # Most SFTP providers only support batch transactions
      def do_send
        raise 'NACHA/SFTP providers do not support individual transactions'
      end

      # Converts this ach transaction to the ACH gem's representation of a
      # ach transaction for eventual NACHA transformation
      # @return [ACH::EntryDetail] ACH gem's ach transaction record
      def to_entry_detail
        entry = ACH::EntryDetail.new
        entry.transaction_code = remove_newlines(transaction_code)
        entry.routing_number = remove_newlines(routing_number)
        entry.account_number = remove_newlines(account_number)
        entry.amount = amount_in_cents
        entry.individual_id_number = remove_newlines(external_ach_id) # Doesn't need to be a number
        entry.individual_name = remove_newlines(merchant_name)
        entry.originating_dfi_identification = remove_newlines(
          self.class.parent.originating_dfi_identification
        )
        entry.trace_number = remove_non_digits(external_ach_id).to_i # Must be number
        entry
      end

      private

      # Removes newlines from given string
      # @param value [String] value to remove newline characters from
      # @return [String] input value with no \n or \r characters
      def remove_newlines(value)
        value.gsub(/[\n\r]/, '')
      end


      # Removes non-digit characters from given string
      # @param value [String] value to remove non-digit characters from
      # @return [String] input value with no non-digit characters
      def remove_non_digits(value)
        value.gsub(/\D/, '')
      end

      def amount_in_cents
        # Take absolute value in case amount is negative
        Helpers::DollarsToCents.dollars_to_cents(amount.abs)
      end

      def transaction_code
        [
          AccountTypeTransformer.serialize_to_provider_value(
            account_type
          ),
          TransactionTypeTransformer.serialize_to_provider_value(
            potentially_flipped_transaction_type
          )
        ].reduce(&:+)
      end

      # Some NACHA providers can't handle negative amounts
      # So we flip the amount and toggle the transaction type between
      #   Debit and Credit or vice versa
      def potentially_flipped_transaction_type
        if amount.negative?
          if transaction_type == TransactionTypes::Credit
            TransactionTypes::Debit
          else
            TransactionTypes::Credit
          end
        else
          self.transaction_type
        end
      end
    end
  end
end
