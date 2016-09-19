module AchClient
  class AchWorks
    ##
    # Transforms AccountTypes between AchClient class and the string
    # that AchWorks expects
    class AccountTypeTransformer < AchClient::Transformer
      # 'C' means Checking, 'S' means Savings
      # @return [Hash {String => Class}] the mapping
      def self.transformer
        {
          'S' => AchClient::AccountTypes::Savings,
          'C' => AchClient::AccountTypes::Checking
        }
      end
    end
  end
end
