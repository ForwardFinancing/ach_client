module AchClient
  class Sftp
    ##
    # Transforms TransactionTypes between AchClient class and the string
    # that NACHA expects
    class TransactionTypeTransformer < AchClient::Transformer
      # '2' means Credit, '7' means Debit
      # The account type string is the second character in the transaction_code
      # field.
      # @return [Hash {String => Class}] the mapping
      def self.transformer
        {
          '2' => AchClient::TransactionTypes::Credit,
          '7' => AchClient::TransactionTypes::Debit
        }
      end
    end
  end
end
