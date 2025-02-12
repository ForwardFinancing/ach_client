require 'test_helper'
class AchWorks
  class TransactionTypeTransformerTest < Minitest::Test
    def test_deserialize_provider_value
      assert_equal(
        AchClient::AchWorks::TransactionTypeTransformer.deserialize_provider_value('C'),
        AchClient::TransactionTypes::Credit
      )

      assert_equal(
        AchClient::AchWorks::TransactionTypeTransformer.deserialize_provider_value('D'),
        AchClient::TransactionTypes::Debit
      )

      assert_equal(
        assert_raises(RuntimeError) do
          AchClient::AchWorks::TransactionTypeTransformer.deserialize_provider_value('Z')
        end.message,
        'Unknown AchClient::AchWorks::TransactionTypeTransformer string Z'
      )
    end

    def test_serialize_to_provider_value
      assert_equal(
        AchClient::AchWorks::TransactionTypeTransformer.serialize_to_provider_value(
          AchClient::TransactionTypes::Credit
        ),
        'C'
      )
      assert_equal(
        AchClient::AchWorks::TransactionTypeTransformer.serialize_to_provider_value(
          AchClient::TransactionTypes::Debit
        ),
        'D'
      )
      assert_equal(
        assert_raises(RuntimeError) do
          AchClient::AchWorks::TransactionTypeTransformer.serialize_to_provider_value(Class)
        end.message,
        'type must be one of AchClient::TransactionTypes::Credit, AchClient::TransactionTypes::Debit'
      )
    end
  end
end
