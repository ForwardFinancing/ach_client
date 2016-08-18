require 'test_helper'

class ResponseRecordProcessorTest < MiniTest::Test
  def test_that_it_handles_method_missing
    assert_equal(
      assert_raises(NoMethodError) do
        AchClient::AchWorks::ResponseRecordProcessor.foo
      end.message,
      "undefined method `foo' for AchClient::AchWorks::ResponseRecordProcessor:Class"
    )
  end
end
