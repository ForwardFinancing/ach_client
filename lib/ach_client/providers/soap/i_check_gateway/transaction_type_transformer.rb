module AchClient
  class ICheckGateway
    # Right now the ICheckGateway transaction type codes are the same as the
    #   AchWorks transaction type codes
    class TransactionTypeTransformer < AchClient::AchWorks::TransactionTypeTransformer
    end
  end
end
