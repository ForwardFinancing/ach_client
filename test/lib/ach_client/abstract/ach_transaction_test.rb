require 'test_helper'

class AchTransactionTest < MiniTest::Test
  def test_abstractfullness
    assert_raises(AbstractMethodError) do
      AchClient::Abstract::AchTransaction.new.send
    end
  end
end
