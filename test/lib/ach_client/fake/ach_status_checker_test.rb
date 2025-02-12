require 'test_helper'

class Fake
  class AchStatusCheckerTest < Minitest::Test
    def test_poll
      start_date = Date.today - 3.days
      end_date = Date.today
      expected_response = {
        'processing' => [AchClient::ProcessingAchResponse.new(amount: 100.0, date: start_date)],
        'settled' => [AchClient::SettledAchResponse.new(amount: 100.0, date: start_date)],
        'returned' => [
          AchClient::ReturnedAchResponse.new(
            amount: 100.0,
            date: start_date,
            return_code: AchClient::ReturnCodes.find_by(code: 'R01')
          )
        ],
        'corrected' => [
          AchClient::CorrectedAchResponse.new(
            amount: 100.0,
            date: start_date,
            return_code: AchClient::ReturnCodes.find_by(code: 'XZ2'),
            corrections: '123456789'
          )
        ],
        'late_returned' => [
          AchClient::SettledAchResponse.new(amount: 100.0, date: start_date),
          AchClient::ReturnedAchResponse.new(
            amount: 100.0,
            date: end_date,
            return_code: AchClient::ReturnCodes.find_by(code: 'R08')
          )
        ]
      }
      assert_equal(AchClient::Fake::AchStatusChecker.most_recent.to_json, expected_response.to_json)
      assert_equal(
        AchClient::Fake::AchStatusChecker.in_range(start_date: start_date, end_date: end_date).to_json,
        expected_response.to_json
      )
    end
  end
end
