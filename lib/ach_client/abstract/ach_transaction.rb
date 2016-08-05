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
          :routing_number,
          :transaction_type
        ]
      end

      attr_reader(*arguments)

      ##
      # @param account_number [String] Merchant's account number
      # @param account_type [AccountTypes::AccountType] Merchant's account type
      #   (debit or credit), must be an instance of AccountTypes::AccountType
      # @param amount [BigDecimal] Amount of the ACH transaction
      # @param memo [String] Ach memo thing
      # @param merchant_name [String] Name associated with merchantaccount we
      #   are ACHing with
      # @param routing_number [String] Routing number of the merchant's account
      # @param transaction_type [TransactionTypes::TransactionType] debit or
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
        transaction_type == TransactionTypes::Debit
      end

      # @return [Boolean] true if transaction is a credit
      def credit?
        transaction_type == TransactionTypes::Credit
      end
    end
  end
end
