module AchClient
  class Sftp
    ##
    # Transforms AccountTypes between AchClient class and the string
    # that NACHA expects
    class AccountTypeTransformer < AchClient::Transformer

      # '2' means Checking, '3' means Savings
      # The account type string is the first character in the transaction_code
      # field.
      # @return [Hash {String => Class}] the mapping
      def self.transformer
        {
          '3' => AchClient::AccountTypes::Savings,
          '2' => AchClient::AccountTypes::Checking
        }
      end
    end
  end
end
