module AchClient
  class ICheckGateway
    # Implementation of AchBatch for ICheckGateway
    class AchBatch < Abstract::AchBatch

      # ICheckGateway does not support ACH batching
      def do_send_batch
        raise 'ICheckGateway does not support ACH batching'
      end
    end
  end
end
