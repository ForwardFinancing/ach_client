require_relative './ach_works_transformer.rb'

module AchClient
  class AchWorks
    ##
    # Transforms TransactionTypes between AchClient class and the string
    # that AchWorks expects
    class TransactionTypeTransformer < AchClient::AchWorks::AchWorksTransformer

      # 'C' means Credit, 'D' means Debit
      # @return [Hash {String => Class}] the mapping
      def self.string_to_class_map
        {
          'C' => TransactionTypes::Credit,
          'D' => TransactionTypes::Debit
        }
      end
    end
  end
end
