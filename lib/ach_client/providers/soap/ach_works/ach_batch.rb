module AchClient
  class AchWorks

    # AchWorks implementation for AchBatch
    class AchBatch < Abstract::AchBatch

      ##
      # Sends the batch to AchWorks using their SendACHTransBatch SOAP action
      # If the action is successful, will return the filename that AchWorks
      # gives us. We can use that to track the batch processing later on.
      # If it fails, an exception will be thrown.
      # @return [Array<String>] the external_ach_id's for each transaction
      def do_send_batch
        AchClient::AchWorks.wrap_request(
          method: :send_ach_trans_batch,
          message: self.to_hash,
          path: [:send_ach_trans_batch_response, :send_ach_trans_batch_result]
        )[:file_name]
        external_ach_ids
      end

      # Converts this batch to a hash which can be sent to ACHWorks via Savon
      # @return [Hash] hash to send to AchWorks
      def to_hash
        CompanyInfo.build.to_hash.merge(
          {
            InpACHFile:{
              SSS: AchClient::AchWorks.s_s_s,
              LocID: AchClient::AchWorks.loc_i_d,
              ACHFileName: nil, # Docs say to leave this blank...
              TotalNumRecords: total_number_records,
              TotalDebitRecords: total_debit_records,
              TotalDebitAmount: total_debit_amount,
              TotalCreditRecords: total_credit_records,
              TotalCreditAmount: total_credit_amount,
              ACHRecords: {
                ACHTransRecord: @ach_transactions.map(&:to_hash)
              }
            }
          }
        )
      end

      private

      def external_ach_ids
        @ach_transactions.map(&:external_ach_id)
      end

      # Because AchWorks can't count...
      def total_number_records
        @ach_transactions.count
      end

      # Because AchWorks can't filter...
      def debit_records
        @ach_transactions.select(&:debit?)
      end

      def credit_records
        @ach_transactions.select(&:credit?)
      end

      # They still don't know how to count.
      def total_debit_records
        debit_records.count
      end

      def total_credit_records
        credit_records.count
      end

      # "Plusing numbers" is real hard as well.
      def total_debit_amount
        total_amount(debit_records)
      end

      def total_credit_amount
        total_amount(credit_records)
      end

      def total_amount(ach_transactions)
        ach_transactions.reduce(0) do |sum, transaction|
          sum + transaction.amount
        end
      end
    end
  end
end
