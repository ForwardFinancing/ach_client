require_relative './ach_works_transformer.rb'

module AchClient
  class AchWorks
    ##
    # Transforms AccountTypes between AchClient class and the string
    # that AchWorks expects
    class AccountTypeTransformer < AchClient::AchWorks::AchWorksTransformer
      # 'C' means Checking, 'S' means Savings
      # @return [Hash {String => Class}] the mapping
      def self.string_to_class_map
        {
          'S' => AchClient::AccountTypes::Savings,
          'C' => AchClient::AccountTypes::Checking
        }
      end
    end
  end
end
