require 'test_helper'
class SiliconValleyBank
  class SiliconValleyBankTest < Minitest::Test
    def test_list_files
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      assert_equal(
        AchClient::SiliconValleyBank.list_files(file_path: '~', glob: '*'),
        ["ACHP08111605", "ACHP08111601", "ACHP08111602"]
      )
    end
    def test_attributes
      assert_equal(AchClient::SiliconValleyBank.immediate_destination,"000000000")
      assert_equal(AchClient::SiliconValleyBank.immediate_destination_name, "Test Destination")
      assert_equal(AchClient::SiliconValleyBank.immediate_origin, "000000000")
      assert_equal(AchClient::SiliconValleyBank.immediate_origin_name, "Test Origin")
      assert_equal(AchClient::SiliconValleyBank.company_identification, "123456789")
      assert_equal(AchClient::SiliconValleyBank.company_entry_description, "idk brah")
      assert_equal(AchClient::SiliconValleyBank.originating_dfi_identification, "00000000")
      assert_equal(AchClient::SiliconValleyBank.host, 'localhost:3000')
      assert_equal(AchClient::SiliconValleyBank.username, 'ebachman@piedpiper.org')
      assert_equal(AchClient::SiliconValleyBank.password, 'AviatoRulez7')
      assert_includes(AchClient::SiliconValleyBank.private_ssh_key, 'PRIVATE KEY')
      assert_equal(AchClient::SiliconValleyBank.transmission_datetime.iso8601, '2016-08-11T10:13:05-04:00')

      AchClient::SiliconValleyBank.immediate_destination = nil
      AchClient::SiliconValleyBank.immediate_destination_name = nil
      AchClient::SiliconValleyBank.immediate_origin = nil
      AchClient::SiliconValleyBank.immediate_origin_name = nil
      AchClient::SiliconValleyBank.company_identification = nil
      AchClient::SiliconValleyBank.company_entry_description = nil
      AchClient::SiliconValleyBank.originating_dfi_identification = nil
      AchClient::SiliconValleyBank.host = nil
      AchClient::SiliconValleyBank.username = nil
      AchClient::SiliconValleyBank.password = nil
      AchClient::SiliconValleyBank.private_ssh_key = nil
      AchClient::SiliconValleyBank.transmission_datetime_calculator = -> { Time.utc(2022) }

      assert_nil(AchClient::SiliconValleyBank.immediate_destination)
      assert_nil(AchClient::SiliconValleyBank.immediate_destination_name)
      assert_nil(AchClient::SiliconValleyBank.immediate_origin)
      assert_nil(AchClient::SiliconValleyBank.immediate_origin_name)
      assert_nil(AchClient::SiliconValleyBank.company_identification)
      assert_nil(AchClient::SiliconValleyBank.company_entry_description)
      assert_nil(AchClient::SiliconValleyBank.originating_dfi_identification)
      assert_nil(AchClient::SiliconValleyBank.host)
      assert_nil(AchClient::SiliconValleyBank.username)
      assert_nil(AchClient::SiliconValleyBank.password)
      assert_nil(AchClient::SiliconValleyBank.private_ssh_key)
      assert_equal(AchClient::SiliconValleyBank.transmission_datetime.iso8601, '2022-01-01T00:00:00Z')


      AchClient::SiliconValleyBank.immediate_destination = '000000000'
      AchClient::SiliconValleyBank.immediate_destination_name = 'Test Destination'
      AchClient::SiliconValleyBank.immediate_origin = '000000000'
      AchClient::SiliconValleyBank.immediate_origin_name = 'Test Origin'
      AchClient::SiliconValleyBank.company_identification = '123456789'
      AchClient::SiliconValleyBank.company_entry_description = 'idk brah'
      AchClient::SiliconValleyBank.originating_dfi_identification = '00000000'
      AchClient::SiliconValleyBank.host = 'localhost:3000'
      AchClient::SiliconValleyBank.username = 'ebachman@piedpiper.org'
      AchClient::SiliconValleyBank.password = 'AviatoRulez7'
      AchClient::SiliconValleyBank.private_ssh_key = "-----BEGIN RSA PRIVATE KEY-----
      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
      -----END RSA PRIVATE KEY-----
      "
      AchClient::SiliconValleyBank.transmission_datetime_calculator = -> { Time.now }
    end
  end
end
