require_relative './returned_ach_response.rb'

module AchClient
  # Representation of an Ach return that contains a correction
  class CorrectedAchResponse < ReturnedAchResponse
    attr_reader :corrections

    ##
    # @param date [DateTime] date of correction return
    # @param return_code [AchClient::ReturnCode] Ach Return code for the
    # correction (ie AchClient::ReturnCodes.find_by(code: 'C01'))
    # @param corrections [Hash] A hash of corrected attributes and their values
    def initialize(amount:, date:, return_code:, corrections:)
      @corrections = corrections
      super(amount: amount, date: date, return_code: return_code)
    end
  end
end
