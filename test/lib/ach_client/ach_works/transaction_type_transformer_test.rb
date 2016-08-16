require 'test_helper'

class TransactionTypeTransformerTest < MiniTest::Test
  def test_string_to_class
    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.string_to_class('C'),
      TransactionTypes::Credit
    )

    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.string_to_class('D'),
      TransactionTypes::Debit
    )

    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::TransactionTypeTransformer.string_to_class('Z')
      end.message,
      'Unknown AchClient::AchWorks::TransactionTypeTransformer string Z'
    )
  end

  def test_class_to_string
    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.class_to_string(
        TransactionTypes::Credit
      ),
      'C'
    )
    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.class_to_string(
        TransactionTypes::Debit
      ),
      'D'
    )
    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::TransactionTypeTransformer.class_to_string(Class)
      end.message,
      'type must be one of TransactionTypes::Credit, TransactionTypes::Debit'
    )
  end
end
