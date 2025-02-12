require 'test_helper'

class Fake
  class AchTransactionTest < Minitest::Test
    def test_transaction
      assert_equal(
        AchClient::Fake::AchTransaction.new(
          external_ach_id: 'test_external_ach_id',
          effective_entry_date: Date.tomorrow
        ).send,
        'test_external_ach_id'
      )
    end
  end
end
