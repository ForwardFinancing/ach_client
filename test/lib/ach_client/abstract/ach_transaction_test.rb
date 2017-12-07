require 'test_helper'

class AchTransactionTest < MiniTest::Test
  def test_abstractfullness
    assert_raises(AbstractMethodError) do
      AchClient::Abstract::AchTransaction.new(
        effective_entry_date: Date.tomorrow
      ).send
    end
  end

  def test_invalid_send
    assert_raises(InvalidAchTransactionError) do
      AchClient::Abstract::AchTransaction.new(
        effective_entry_date: Date.yesterday
      ).send
    end
  end
end
