module AchClient
  class AchWorks

    # AchWorks implementation for AchBatch
    class AchBatch < Abstract::AchBatch

      ##
      # Sends the batch to AchWorks using their SendACHTransBatch SOAP action
      # If the action is successful, will return the filename that AchWorks
      # gives us. We can use that to track the batch processing later on.
      # If it fails, an exception will be thrown.
      # @return [String] the filename they give us for later tracking
      def send_batch
        response = get_response
        # Success on the response object just means that request was a 200
        if response.success?
          result = response.body[:send_ach_trans_batch_response]
          result = result[:send_ach_trans_batch_result]
          if result[:status] == 'SUCCESS'
            result[:file_name]
          else
            # AchWorks likes to keep things interesting by sometimes putting
            # the error messages in the details field instead of errors.
            raise result.try(:[], :errors)
                        .try(:[], :string)
                        .try(:join, ', ') ||
                  result[:details]
          end
        else
          # This would normally raise an exception on its own, but just in case
          raise 'ACH Batch failed due to unknown SOAP fault'
        end
      end

      # Makes a SendACHTransBatch SOAP request to AchWorks with this object
      # represented in the request body (XML)
      def get_response
        AchClient::AchWorks.soap_client.call(
          :send_ach_trans_batch,
          message: self.to_hash
        )
      end

      # Converts this batch to a hash which can be sent to ACHWorks via Savon
      # @return [Hash] hash to send to AchWorks
      def to_hash
        InputCompanyInfo.build.to_hash.merge(
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
