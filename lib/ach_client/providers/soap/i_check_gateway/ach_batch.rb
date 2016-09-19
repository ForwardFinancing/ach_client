module AchClient
  class ICheckGateway
    # Implementation of AchBatch for ICheckGateway
    class AchBatch < Abstract::AchBatch

      # ICheckGateway don't do no batches
      def send_batch
        raise 'ICheckGateway does not support ACH batching'
      end
    end
  end
end
