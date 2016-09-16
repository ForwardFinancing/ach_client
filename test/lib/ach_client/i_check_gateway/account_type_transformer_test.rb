require 'test_helper'

class AccountTypeTransformerTest < MiniTest::Test
  def test_deserialize_provider_value
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.deserialize_provider_value('PC'),
      AchClient::AccountTypes::PersonalChecking
    )

    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.deserialize_provider_value('PS'),
      AchClient::AccountTypes::PersonalSavings
    )

    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.deserialize_provider_value('BC'),
      AchClient::AccountTypes::BusinessChecking
    )

    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.deserialize_provider_value('BS'),
      AchClient::AccountTypes::BusinessSavings
    )

    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::ICheckGateway::AccountTypeTransformer.deserialize_provider_value('Z')
      end.message,
      'Unknown AchClient::ICheckGateway::AccountTypeTransformer string Z'
    )
  end

  def test_serialize_to_provider_value
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::BusinessSavings
      ),
      'BS'
    )
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::PersonalSavings
      ),
      'PS'
    )
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::PersonalChecking
      ),
      'PC'
    )
    assert_equal(
      AchClient::ICheckGateway::AccountTypeTransformer.serialize_to_provider_value(
        AchClient::AccountTypes::BusinessChecking
      ),
      'BC'
    )
    assert_equal(
      assert_raises(RuntimeError) do
        AchClient::ICheckGateway::AccountTypeTransformer.serialize_to_provider_value(Class)
      end.message,
      'type must be one of AchClient::AccountTypes::PersonalSavings, AchClient::AccountTypes::PersonalChecking, AchClient::AccountTypes::BusinessSavings, AchClient::AccountTypes::BusinessChecking'
    )
  end
end
