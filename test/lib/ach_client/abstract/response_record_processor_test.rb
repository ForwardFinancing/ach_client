require 'test_helper'

class Abstract
  class ResponseRecordProcessorTest < MiniTest::Test
    def test_abstractlyness
      assert_raises(AbstractMethodError) do
        AchClient::Abstract::ResponseRecordProcessor.process_response_record(
          'foo'
        )
      end
    end
  end
end
