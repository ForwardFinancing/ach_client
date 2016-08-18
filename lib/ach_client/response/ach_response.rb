module AchClient
  # Abstract Response wrapper for the various ACH response statuses
  class AchResponse

    # Date the Ach was in this status
    attr_reader :date

    def initialize(date:)
      raise AbstractMethodError if self.class == AchClient::AchResponse
      @date = date
    end
  end
end
