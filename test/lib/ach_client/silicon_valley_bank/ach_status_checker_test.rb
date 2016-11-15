require 'test_helper'

class SiliconValleyBank
  class AchStatusCheckerTest < MiniTest::Test
    def test_most_recent
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      response = AchClient::SiliconValleyBank::AchStatusChecker.most_recent
      assert response["T005"].is_a?(AchClient::SettledAchResponse)
      assert_equal response["T005"].date, Date.parse("Fri, 11 Nov 2011")
    end

    def test_in_range
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      response = AchClient::SiliconValleyBank::AchStatusChecker.in_range(
        start_date: Date.yesterday - 1.day,
        end_date: Date.tomorrow
      )
      assert response["T005"].is_a?(AchClient::SettledAchResponse)
      assert_equal response["T005"].date, Date.parse("Fri, 11 Nov 2011")

      assert response["CUSTIDNO"].is_a?(AchClient::CorrectedAchResponse)
      assert_equal response["CUSTIDNO"].corrections, {
        unhandled_correction_data: "051400549   2018413280533"
      }
      assert_equal response["CUSTIDNO"].date, Date.parse("Fri, 15 Jul 2011")
      assert_equal(
        response["CUSTIDNO"].return_code,
        AchClient::ReturnCodes.find_by(code: 'C03')
      )

      assert response["CUSTID1"].is_a?(AchClient::ReturnedAchResponse)
      assert_equal response["CUSTID1"].date, Date.parse("Fri, 15 Jul 2011")
      assert_equal(
        response["CUSTID1"].return_code,
        AchClient::ReturnCodes.find_by(code: 'R03')
      )
    end
  end
end
