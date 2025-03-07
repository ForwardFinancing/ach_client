require 'test_helper'
class SiliconValleyBank
  class AccountTypeTransformerTest < Minitest::Test
    def test_deserialize_provider_value
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.deserialize_provider_value('2'),
        AchClient::AccountTypes::Checking
      )

      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.deserialize_provider_value('3'),
        AchClient::AccountTypes::Savings
      )

      assert_equal(
        assert_raises(RuntimeError) do
          AchClient::Sftp::AccountTypeTransformer.deserialize_provider_value('Z')
        end.message,
        'Unknown AchClient::Sftp::AccountTypeTransformer string Z'
      )
    end

    def test_serialize_to_provider_value
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(
          AchClient::AccountTypes::Checking
        ),
        '2'
      )
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(
          AchClient::AccountTypes::Savings
        ),
        '3'
      )
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(
          AchClient::AccountTypes::BusinessSavings
        ),
        '3'
      )
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(
          AchClient::AccountTypes::PersonalSavings
        ),
        '3'
      )
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(
          AchClient::AccountTypes::PersonalChecking
        ),
        '2'
      )
      assert_equal(
        AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(
          AchClient::AccountTypes::BusinessChecking
        ),
        '2'
      )
      assert_equal(
        assert_raises(RuntimeError) do
          AchClient::Sftp::AccountTypeTransformer.serialize_to_provider_value(Class)
        end.message,
        'type must be one of AchClient::AccountTypes::Savings, AchClient::AccountTypes::Checking'
      )
    end
  end
end
