require 'test_helper'

class AchBatchTest < MiniTest::Test
  def test_abstractfulness
    assert_raises(AbstractMethodError) do
      AchClient::Abstract::AchBatch.new.send_batch
    end
  end
end
