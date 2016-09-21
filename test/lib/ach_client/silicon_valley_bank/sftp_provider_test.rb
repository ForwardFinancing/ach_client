class SiliconValleyBank
  class SftpProviderTest < MiniTest::Test
    def test_retrieve_files
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
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
    end
  end
end
