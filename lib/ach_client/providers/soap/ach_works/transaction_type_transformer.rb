module AchClient
  class AchWorks
    ##
    # Transforms TransactionTypes between AchClient class and the string
    # that AchWorks expects
    class TransactionTypeTransformer < AchClient::Transformer

      # 'C' means Credit, 'D' means Debit
      # @return [Hash {String => Class}] the mapping
      def self.transformer
        {
          'C' => AchClient::TransactionTypes::Credit,
          'D' => AchClient::TransactionTypes::Debit
        }
      end
    end
  end
end
