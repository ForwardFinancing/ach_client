module AchClient
  class Fake
    class AchBatch < Abstract::AchBatch

      # Fake batch ACH sending just returns the provided external_ach_ids to indicate success
      def do_send_batch
        @ach_transactions.map(&:external_ach_id)
      end
    end
  end
end
