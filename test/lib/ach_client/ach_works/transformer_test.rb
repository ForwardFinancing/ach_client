require 'test_helper'

class TransformerTest < MiniTest::Test
  def test_abstractlyness
    assert_raises(AbstractMethodError) do
      AchClient::AchWorks::AchWorksTransformer.string_to_class_map
    end
  end
end
