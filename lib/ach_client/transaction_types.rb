module AchClient
  ## Representations of Ach transaction types (debit or credit)
  module TransactionTypes
    ## Base class for all transaction types
    class TransactionType
    end

    ## Representation of a credit transaction type
    class Credit < AchClient::TransactionTypes::TransactionType
    end

    ## Representation of a debit transaction type
    class Debit < AchClient::TransactionTypes::TransactionType
    end
  end
end
