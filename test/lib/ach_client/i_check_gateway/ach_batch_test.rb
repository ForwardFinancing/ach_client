require 'test_helper'

class ICheckGateway
  class AchBatchTest < MiniTest::Test
    def test_not_supported
      assert_raises(RuntimeError) do
        AchClient::ICheckGateway::AchBatch.new(ach_transactions: []).send_batch
      end
    end
  end
end
