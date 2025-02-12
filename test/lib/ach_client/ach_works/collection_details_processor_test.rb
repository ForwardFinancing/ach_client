require 'test_helper'

class AchWorks
  class CorrectionDetailsProcessorTest < Minitest::Test
    def test_that_it_handles_method_missing
      assert_raises(NoMethodError) do
        AchClient::AchWorks::CorrectionDetailsProcessor.foo
      end
    end
  end
end
