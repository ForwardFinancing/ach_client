module AchClient
  class Abstract

    # Generic representation of a single Ach transaction
    class AchTransaction

      ##
      # @return [Array] A list of arguments to use in the initializer, and as
      # instance attributes
      def self.arguments
        [
          :account_number,
          :account_type,
          :amount,
          :memo,
          :merchant_name,
          :originator_name,
          :routing_number,
          :sec_code,
          :transaction_type
        ]
      end

      attr_reader(*arguments)

      ##
      # @param account_number [String] Merchant's account number
      # @param account_type [AchClient::AccountTypes::AccountType] Merchant's account type
      #   (debit or credit), must be an instance of AchClient::AccountTypes::AccountType
      # @param amount [BigDecimal] Amount of the ACH transaction
      # @param memo [String] Ach memo thing
      # @param merchant_name [String] Name associated with merchantaccount we
      #   are ACHing with
      # @param originator_name [String] String identifying you, will appear on
      #   merchants bank statement
      # @param routing_number [String] Routing number of the merchant's account
      # @param sec_code [String] CCD, PPD, WEB, etc.
      #  See: https://en.wikipedia.org/wiki/Automated_Clearing_House#SEC_codes
      # @param transaction_type [AchClient::TransactionTypes::TransactionType] debit or
      def initialize(*arguments)
        args = arguments.extract_options!
        self.class.arguments.each do |param|
          self.instance_variable_set(
            "@#{param}".to_sym,
            args[param]
          )
        end
      end

      # @return [Boolean] true if transaction is a debit
      def debit?
        transaction_type == AchClient::TransactionTypes::Debit
      end

      # @return [Boolean] true if transaction is a credit
      def credit?
        transaction_type == AchClient::TransactionTypes::Credit
      end
    end
  end
end
