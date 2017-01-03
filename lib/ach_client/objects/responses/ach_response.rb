module AchClient
  # Abstract Response wrapper for the various ACH response statuses
  class AchResponse


    attr_reader :amount, # Amount of the processed ACH
                :date # Date the Ach was in this status

    def initialize(amount:, date:)
      raise AbstractMethodError if self.class == AchClient::AchResponse
      @amount = amount
      @date = date
    end
  end
end
