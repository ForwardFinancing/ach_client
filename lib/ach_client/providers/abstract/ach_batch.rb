module AchClient
  # Abstract Ach provider, which all other provider's inherit from
  class Abstract

    # Base class for sending batched ACH transactions to various providers
    class AchBatch

      ##
      # @param ach_transactions [Array] List of AchTransaction objects to batch
      def initialize(ach_transactions: [])
        @ach_transactions = ach_transactions
      end

      ##
      # Sends the batch to the provider, and returns a tracking identifier
      # @return [Array<String>] Identifiers to use to poll for result of batch
      # processing later on.
      def send_batch
        if @ach_transactions.all?(&:sendable?)
          do_send_batch
        else
          raise InvalidAchTransactionError
        end
      end

      # Implementation of sending the ACH batch to the provider, to be
      #   implemented by the subclass
      # @return [Array<String>] Identifiers to use to poll for result of batch
      # processing later on.
      def do_send_batch
        raise AbstractMethodError
      end
    end
  end
end
