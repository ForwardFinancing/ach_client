module AchClient
  ## Representations of merchant account types (checking or savings)
  module AccountTypes
    ## Base class for all account types
    class AccountType
    end

    ## Represents a checking account
    class Checking < AchClient::AccountTypes::AccountType
    end

    ## Represents a savings account
    class Savings < AchClient::AccountTypes::AccountType
    end

    ## Represents a business checking account
    class BusinessChecking < AchClient::AccountTypes::Checking
    end

    ## Represents a business savings account
    class BusinessSavings < AchClient::AccountTypes::Savings
    end

    ## Represents a personal checking account
    class PersonalChecking < AchClient::AccountTypes::Checking
    end

    ## Represents a personal savings account
    class PersonalSavings < AchClient::AccountTypes::Savings
    end
  end
end
