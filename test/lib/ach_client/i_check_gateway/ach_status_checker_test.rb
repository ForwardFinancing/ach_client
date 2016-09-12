require 'test_helper'

class AchStatusCheckerTest < MiniTest::Test
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

  def test_in_range_success
    VCR.use_cassette('icg_in_range_success') do
      assert_equal(
        AchClient::ICheckGateway::AchStatusChecker.in_range(
          start_date: Date.yesterday,
          end_date: Date.today
        ).to_json,
        {
          'ef69436stub0' => AchClient::ProcessingAchResponse.new(
            date: '9/12/2016'
          ),
          'cb4e1d6stub1' => AchClient::SettledAchResponse.new(
            date: '9/6/2016'
          ),
          '7370d7dstub2' => AchClient::ReturnedAchResponse.new(
            date: '9/7/2016',
            return_code: AchClient::ReturnCodes.find_by(code: 'R08')
          ),
          'c4918f8stub3' => AchClient::ReturnedAchResponse.new(
            date: '9/6/2016',
            return_code: AchClient::ReturnCodes.find_by(code: 'R01')
          )
        }.to_json
      )
    end
  end
end
