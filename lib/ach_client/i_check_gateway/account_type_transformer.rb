module AchClient
  class ICheckGateway
    ##
    # Transforms AccountTypes between AchClient class and the string
    # that ICheckGateway expects
    class AccountTypeTransformer < AchClient::Transformer
      # 'B' means Business, 'P' means Personal
      # 'C' means Checking, 'S' means Savings
      # @return [Hash {String => Class}] the mapping
      def self.transformer
        {
          'PS' => AchClient::AccountTypes::PersonalSavings,
          'PC' => AchClient::AccountTypes::PersonalChecking,
          'BS' => AchClient::AccountTypes::BusinessSavings,
          'BC' => AchClient::AccountTypes::BusinessChecking
        }
      end
    end
  end
end
