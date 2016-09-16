require 'test_helper'

class TransformerTest < MiniTest::Test
  def test_abstractlyness
    assert_raises(AbstractMethodError) do
      AchClient::Transformer.transformer
    end
  end
end
