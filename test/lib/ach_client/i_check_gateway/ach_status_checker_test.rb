require 'test_helper'
class ICheckGateway
  class AchStatusCheckerTest < Minitest::Test
    # SOAP APIs all use the same URL, so we must define a custom request
    #   matcher when there is more than one cassette
    def vcr_options
      {
        match_requests_on: [
          lambda do |left_request, right_request|
            left_request.uri == right_request.uri &&
              left_request.headers["Soapaction"] == right_request.headers["Soapaction"] &&
              # At somepoint due to savon updates extra stuff was added to headers that we don't care about
              Hash.from_xml(right_request.body)["Envelope"]["Body"] ==
                Hash.from_xml(left_request.body)["Envelope"]["Body"]
          end
        ]
      }
    end

    def test_most_recent
      assert_raises(RuntimeError) do
        AchClient::ICheckGateway::AchStatusChecker.most_recent
      end
    end

    def test_in_range_unexpected
      VCR.use_cassette('icg_in_range_unexpected') do
        assert_equal(
          assert_raises(RuntimeError) do
            AchClient::ICheckGateway::AchStatusChecker.in_range(
              start_date: Date.tomorrow,
              end_date: Date.today
            )
          end.message,
          "Couldnt process ICheckGateway Response: ICHECK|Z||ef69436stub0|STUB0||||||||BC|012345678|********1234|250.00|D|9/12/2016|05:03:04|C2952-1927||AutoCheck|||STUB0|CCD|||\\r\\n"
        )
      end
    end

    def test_in_range_rate_limit
      VCR.use_cassette('icg_in_range_rate_limit') do
        assert_equal(
          assert_raises(RuntimeError) do
            AchClient::ICheckGateway::AchStatusChecker.in_range(
              start_date: Date.tomorrow,
              end_date: Date.today
            )
          end.message,
          "Couldnt process ICheckGateway Response: ACCESS DENIED: Report Call Limit Exceeded"
        )
      end
    end

    def test_in_range_rate_limit
      VCR.use_cassette('icg_in_range_range_limit') do
        assert_equal(
          assert_raises(RuntimeError) do
            AchClient::ICheckGateway::AchStatusChecker.in_range(
              start_date: Date.tomorrow,
              end_date: Date.today
            )
          end.message,
          "Couldnt process ICheckGateway Response: ACCESS DENIED: Date Range Exceeds 15 Days"
        )
      end
    end

    def test_in_range_empty_returns
      # Make sure status checker doesn't raise an error when one of the requests to the late returns endpoint returns
      #  no results
      VCR.use_cassettes([
        {name: 'icg_in_range_success', options: vcr_options},
        {name: 'icg_late_returns_empty', options: vcr_options},
        {name: 'icg_late_returns_b', options: vcr_options}
      ]) do
        assert AchClient::ICheckGateway::AchStatusChecker.in_range(
          start_date: Date.yesterday,
          end_date: Date.today
        )
      end
    end

    def test_in_range_returns_error
      VCR.use_cassettes([
        {name: 'icg_in_range_success', options: vcr_options},
        {name: 'icg_late_returns_error', options: vcr_options},
      ]) do
        assert_equal(
          assert_raises(RuntimeError) do
            AchClient::ICheckGateway::AchStatusChecker.in_range(
              start_date: Date.yesterday,
              end_date: Date.today
            )
          end.message,
          "Couldnt process ICheckGateway Late Returns Response: HERE IS AN UNDOCUMENTED API ERROR"
        )
      end
    end

    def test_in_range_success

      VCR.use_cassettes([
        {name: 'icg_in_range_success', options: vcr_options},
        {name: 'icg_late_returns_a', options: vcr_options},
        {name: 'icg_late_returns_b', options: vcr_options}
      ]) do
        expected = {
          'pending_and_settled' => [
            AchClient::ProcessingAchResponse.new(
              amount: '250.00',
              date: Date.parse('12/9/2016')
            ),
            AchClient::SettledAchResponse.new(
              amount: '250.00',
              date: Date.parse('12/9/2016')
            )
          ],
          'settled1' => [AchClient::SettledAchResponse.new(
            amount: '906.43',
            date: Date.parse('6/9/2016')
          )],
          'accountclosed' => [AchClient::ReturnedAchResponse.new(
            amount: '176.10',
            date: Date.parse('7/9/2016'),
            return_code: AchClient::ReturnCodes.find_by(code: 'R08')
          )],
          'nsf' => [
            AchClient::ReturnedAchResponse.new(
              amount: nil,
              date: Date.parse('2016-08-10'),
              return_code: AchClient::ReturnCodes.find_by(code: 'R01')
            ),
            AchClient::ReturnedAchResponse.new(
              amount: '178.75',
              date: Date.parse('6/9/2016'),
              return_code: AchClient::ReturnCodes.find_by(code: 'R01')
            )
          ],
          'short_late_return' => [
            AchClient::ReturnedAchResponse.new(
              amount: nil,
              date: Date.parse('2016-08-10'),
              return_code: AchClient::ReturnCodes.find_by(code: 'R08')
            ),
            AchClient::SettledAchResponse.new(
              amount: '123.45',
              date: Date.parse('10/08/2016')
            )
          ],
          'very_late_return' => [
            AchClient::ReturnedAchResponse.new(
              amount: nil,
              date: Date.parse('2016-08-11'),
              return_code: AchClient::ReturnCodes.find_by(code: 'R02')
            )
          ]
        }.sort.to_json
        actual = AchClient::ICheckGateway::AchStatusChecker.in_range(
          start_date: Date.yesterday,
          end_date: Date.today
        ).sort.to_json
        assert_equal(JSON.parse(expected).to_h, JSON.parse(actual).to_h)
      end
    end
  end
end
