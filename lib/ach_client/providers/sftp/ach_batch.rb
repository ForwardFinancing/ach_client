module AchClient
  # Namespace for all things Sftp
  class Sftp
    # NACHA representation of an AchBatch
    class AchBatch < Abstract::AchBatch

      def initialize(ach_transactions: [], batch_number: nil)
        super(ach_transactions: ach_transactions)
        @batch_number = batch_number
      end

      # The filename used for the batch
      # @return [String] filename to use
      def batch_file_name
        self.class.parent.file_naming_strategy.(@batch_number)
      end

      # Sends the batch to SFTP provider
      # @return [Array<String>]
      def do_send_batch
        self.class.parent.write_remote_file(
          file_path: File.join(
            self.class.parent.outgoing_path,
            batch_file_name
          ),
          file_body: cook_some_nachas.to_s
        )
        @ach_transactions.map(&:external_ach_id)
      end

      # Converts this AchBatch into the NACHA object representation provided
      # by the ACH gem.
      # @return [ACH::ACHFile] Yo NACHA
      def cook_some_nachas
        nacha = ACH::ACHFile.new
        nacha.instance_variable_set(:@header, nacha_file_header)

        # The NACHA can have multiple batches.
        # Transactions in the same batch must have the same originator and
        # sec_code, so we group by sec_code and originator when building batches
        @ach_transactions.group_by(&:sec_code).map do |sec_code, transactions|
          transactions.group_by(&:originator_name)
                      .map do |originator_name, batch_transactions|
            batch_transactions.group_by(&:effective_entry_date)
                            .map do |effective_entry_date, batched_transactions|
              nacha.batches << nacha_batch(
                sec_code,
                originator_name,
                effective_entry_date,
                batched_transactions
              )
            end
          end
        end
        nacha
      end

      private
      def nacha_file_header
        file_header = ACH::Records::FileHeader.new
        [
          :immediate_destination,
          :immediate_destination_name,
          :immediate_origin,
          :immediate_origin_name
        ].each do |attribute|
          file_header.send("#{attribute}=", self.class.parent.send(attribute))
        end
        file_header
      end

      def nacha_batch(
        sec_code,
        originator_name,
        effective_entry_date,
        transactions
      )
        batch = ACH::Batch.new
        batch_header = batch.header
        batch_header.company_name = originator_name
        batch_header.company_identification =
          self.class.parent.company_identification
        batch_header.standard_entry_class_code = sec_code
        batch_header.company_entry_description =
          self.class.parent.company_entry_description
        batch_header.company_descriptive_date = effective_entry_date
        batch_header.effective_entry_date = effective_entry_date
        batch_header.originating_dfi_identification =
          self.class.parent.originating_dfi_identification
        transactions.each do |transaction|
          batch.entries << transaction.to_entry_detail
        end
        batch
      end
    end
  end
end
