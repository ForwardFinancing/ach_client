require 'test_helper'

class AccountTypeTransformerTest < MiniTest::Test
  def test_string_to_class
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.string_to_class('PC'),
      AchClient::AccountTypes::PersonalChecking
    )

    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.string_to_class('PS'),
      AchClient::AccountTypes::PersonalSavings
    )

    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.string_to_class('BC'),
      AchClient::AccountTypes::BusinessChecking
    )

    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.string_to_class('BS'),
      AchClient::AccountTypes::BusinessSavings
    )

    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::ICheckGateway::AccountTypeTransformer.string_to_class('Z')
      end.message,
      'Unknown AchClient::ICheckGateway::AccountTypeTransformer string Z'
    )
  end

  def test_class_to_string
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.class_to_string(
        AchClient::AccountTypes::BusinessSavings
      ),
      'BS'
    )
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.class_to_string(
        AchClient::AccountTypes::PersonalSavings
      ),
      'PS'
    )
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.class_to_string(
        AchClient::AccountTypes::PersonalChecking
      ),
      'PC'
    )
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.class_to_string(
        AchClient::AccountTypes::BusinessChecking
      ),
      'BC'
    )
    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::ICheckGateway::AccountTypeTransformer.class_to_string(Class)
      end.message,
      'type must be one of AchClient::AccountTypes::PersonalSavings, AchClient::AccountTypes::PersonalChecking, AchClient::AccountTypes::BusinessSavings, AchClient::AccountTypes::BusinessChecking'
    )
  end
end
