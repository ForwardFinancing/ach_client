require 'test_helper'

class AchWorks
  class CorrectionDetailsProcessorTest < MiniTest::Test
    def test_that_it_handles_method_missing
      assert_equal(
        assert_raises(NoMethodError) do
          AchClient::AchWorks::CorrectionDetailsProcessor.foo
        end.message,
        "undefined method `foo' for AchClient::AchWorks::CorrectionDetailsProcessor:Class"
      )
    end
  end
end
