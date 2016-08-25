require 'test_helper'

class TransactionTypeTransformerTest < MiniTest::Test
  def test_string_to_class
    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.string_to_class('C'),
      AchClient::TransactionTypes::Credit
    )

    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.string_to_class('D'),
      AchClient::TransactionTypes::Debit
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
        AchClient::TransactionTypes::Credit
      ),
      'C'
    )
    assert_equal(
      AchClient::AchWorks::TransactionTypeTransformer.class_to_string(
        AchClient::TransactionTypes::Debit
      ),
      'D'
    )
    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::TransactionTypeTransformer.class_to_string(Class)
      end.message,
      'type must be one of AchClient::TransactionTypes::Credit, AchClient::TransactionTypes::Debit'
    )
  end
end
