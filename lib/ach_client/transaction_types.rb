## Representations of Ach transaction types (debit or credit)
module TransactionTypes
  ## Base class for all transaction types
  class TransactionType
  end

  ## Representation of a credit transaction type
  class Credit < TransactionTypes::TransactionType
  end

  ## Representation of a debit transaction type
  class Debit < TransactionTypes::TransactionType
  end
end
