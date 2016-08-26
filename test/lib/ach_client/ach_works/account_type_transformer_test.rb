require 'test_helper'

class AccountTypeTransformerTest < MiniTest::Test
  def test_string_to_class
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.string_to_class('C'),
      AchClient::AccountTypes::Checking
    )

    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.string_to_class('S'),
      AchClient::AccountTypes::Savings
    )

    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::AccountTypeTransformer.string_to_class('Z')
      end.message,
      'Unknown AchClient::AchWorks::AccountTypeTransformer string Z'
    )
  end

  def test_class_to_string
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.class_to_string(
        AchClient::AccountTypes::Checking
      ),
      'C'
    )
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.class_to_string(
        AchClient::AccountTypes::Savings
      ),
      'S'
    )
    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::AccountTypeTransformer.class_to_string(Class)
      end.message,
      'type must be one of AchClient::AccountTypes::Savings, AchClient::AccountTypes::Checking'
    )
  end
end
