require 'test_helper'

class SiliconValleyBank
  class TransactionTypeTransformerTest < Minitest::Test
    def test_deserialize_provider_value
      assert_equal(
        AchClient::Sftp::TransactionTypeTransformer.deserialize_provider_value('2'),
        AchClient::TransactionTypes::Credit
      )

      assert_equal(
        AchClient::Sftp::TransactionTypeTransformer.deserialize_provider_value('7'),
        AchClient::TransactionTypes::Debit
      )

      assert_equal(
        assert_raises(RuntimeError) do
          AchClient::Sftp::TransactionTypeTransformer.deserialize_provider_value('Z')
        end.message,
        'Unknown AchClient::Sftp::TransactionTypeTransformer string Z'
      )
    end

    def test_serialize_to_provider_value
      assert_equal(
        AchClient::Sftp::TransactionTypeTransformer.serialize_to_provider_value(
          AchClient::TransactionTypes::Credit
        ),
        '2'
      )
      assert_equal(
        AchClient::Sftp::TransactionTypeTransformer.serialize_to_provider_value(
          AchClient::TransactionTypes::Debit
        ),
        '7'
      )
      assert_equal(
        assert_raises(RuntimeError) do
          AchClient::Sftp::TransactionTypeTransformer.serialize_to_provider_value(Class)
        end.message,
        'type must be one of AchClient::TransactionTypes::Credit, AchClient::TransactionTypes::Debit'
      )
    end
  end
end
