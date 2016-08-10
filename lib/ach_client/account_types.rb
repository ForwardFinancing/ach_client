## Representations of merchant account types (checking or savings)
module AccountTypes
  ## Base class for all account types
  class AccountType
  end

  ## Represents a checking account
  class Checking < AccountTypes::AccountType
  end

  ## Represents a savings account
  class Savings < AccountTypes::AccountType
  end
end
