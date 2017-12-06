require 'test_helper'

class Abstract
  class AchBatchTest < MiniTest::Test
    def test_abstractfulness
      assert_raises(AbstractMethodError) do
        AchClient::Abstract::AchBatch.new.send_batch
      end

      assert_raises(InvalidAchTransactionError) do
        AchClient::Abstract::AchBatch.new(
          ach_transactions: [
            AchClient::Abstract::AchTransaction.new(
              effective_entry_date: Date.yesterday
            )
          ]
        ).send_batch
      end
    end
  end
end
