module AchClient
  class Fake
    # Fake ACH polling that always returns the same set of results.
    class AchStatusChecker < Abstract::AchStatusChecker

      def self.most_recent
        in_range(start_date: Date.today - 3.days, end_date: Date.today)
      end

      def self.in_range(start_date:, end_date:)
        {
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
      end

    end
  end
end
