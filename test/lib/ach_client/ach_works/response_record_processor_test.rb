require 'test_helper'

class AchWorks
  class ResponseRecordProcessorTest < MiniTest::Test
    def test_that_it_handles_method_missing
      assert_raises(NoMethodError) do
        AchClient::AchWorks::ResponseRecordProcessor.foo
      end
    end
  end
end
