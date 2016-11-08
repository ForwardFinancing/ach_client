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
    end
  end
end
