module AchClient
  # Representation of an Ach return that failed
  class ReturnedAchResponse < AchResponse

    attr_reader :return_code

    ##
    # @param date [DateTime] date of correction return
    # @param return_code [AchClient::ReturnCode] Ach Return code for the
    # correction (ie AchClient::ReturnCodes.find_by(code: 'C01'))
    def initialize(amount:, date:, return_code:)
      @return_code = return_code
      super(amount: amount, date: date)
    end
  end
end
