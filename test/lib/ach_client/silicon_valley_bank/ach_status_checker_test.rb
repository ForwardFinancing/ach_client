require 'test_helper'

class SiliconValleyBank
  class AchStatusCheckerTest < MiniTest::Test
    def test_most_recent
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      response = AchClient::SiliconValleyBank::AchStatusChecker.most_recent
      assert response["T005"].is_a?(AchClient::SettledAchResponse)
      assert_equal response["T005"].date, Date.parse("Fri, 11 Nov 2011")
    end

    def test_most_recent_no_such_file
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      # The exception should be caught and the results should be the same as
      #   normal test
      FakeSFTPConnection.stubs(:most_recent).raises(
        Net::SFTP::StatusException.new(OpenStruct.new({code: 2}))
      )
      response = AchClient::SiliconValleyBank::AchStatusChecker.most_recent
      assert response["T005"].is_a?(AchClient::SettledAchResponse)
      assert_equal response["T005"].date, Date.parse("Fri, 11 Nov 2011")
    end

    def test_most_recent_other_exception
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      FakeSFTPConnection.stubs(:open).with('/most_recent', 'r').raises(
        Net::SFTP::StatusException.new(OpenStruct.new({code: 1}))
      )
      assert_raises(Net::SFTP::StatusException) do
        AchClient::SiliconValleyBank::AchStatusChecker.most_recent
      end
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

    def test_process_files_with_no_files
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      AchClient::SiliconValleyBank::AchStatusChecker.any_instance.stubs(
        :most_recent_files
      ).returns(nil)
      assert(AchClient::SiliconValleyBank::AchStatusChecker.most_recent)
    end
  end
end
