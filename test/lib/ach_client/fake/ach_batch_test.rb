require 'test_helper'

class Fake
  class AchBatchTest < Minitest::Test
    def test_batch
      assert_equal(
        AchClient::Fake::AchBatch.new(
          ach_transactions: [
            AchClient::Fake::AchTransaction.new(
              external_ach_id: 'test_external_ach_id',
              effective_entry_date: Date.tomorrow
            )
          ]
        ).send_batch,
        ['test_external_ach_id']
      )
    end
  end
end
