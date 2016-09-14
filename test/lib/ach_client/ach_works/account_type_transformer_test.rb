require 'test_helper'

class AccountTypeTransformerTest < MiniTest::Test
  def test_deserialize_provider_value
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.deserialize_provider_value('C'),
      AchClient::AccountTypes::Checking
    )

    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.deserialize_provider_value('S'),
      AchClient::AccountTypes::Savings
    )

    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::AccountTypeTransformer.deserialize_provider_value('Z')
      end.message,
      'Unknown AchClient::AchWorks::AccountTypeTransformer string Z'
    )
  end

  def test_serialize_to_provider_value
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::Checking
      ),
      'C'
    )
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::Savings
      ),
      'S'
    )
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::BusinessSavings
      ),
      'S'
    )
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::PersonalSavings
      ),
      'S'
    )
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::PersonalChecking
      ),
      'C'
    )
    assert_equal(
      AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::BusinessChecking
      ),
      'C'
    )
    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::AchWorks::AccountTypeTransformer.serialize_to_provider_value(Class)
      end.message,
      'type must be one of AchClient::AccountTypes::Savings, AchClient::AccountTypes::Checking'
    )
  end
end
