class SiliconValleyBank
  class SftpProviderTest < MiniTest::Test
    def test_retrieve_files
      AchClient::Logging.stub(
        :log_provider,
        AchClient::Logging::StdoutLogProvider
      ) do
        Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
        log_output = capture_subprocess_io do
          assert_equal(
            AchClient::SiliconValleyBank.retrieve_files(
              file_path: './test_directory',
              glob: '*'
            ),
            {
              "ACHP08111605" => "test file contents blah blah blah",
              "ACHP08111601" => "test file contents blah blah blah",
              "ACHP08111602" => "test file contents blah blah blah"
            }
          )
        end.first
        # Make sure logging worked too
        assert_equal(
          log_output,
          "response-2016-08-11T10:13:05-04:00-ACHP08111605\ntest file contents blah blah blah\nresponse-2016-08-11T10:13:05-04:00-ACHP08111601\ntest file contents blah blah blah\nresponse-2016-08-11T10:13:05-04:00-ACHP08111602\ntest file contents blah blah blah\n"
        )
      end
    end
  end
end
