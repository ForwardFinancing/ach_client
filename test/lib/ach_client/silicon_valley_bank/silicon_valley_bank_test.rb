require 'test_helper'
class SiliconValleyBank
  class SiliconValleyBankTest < MiniTest::Test
    def test_attributes
      assert_equal(AchClient::SiliconValleyBank.immediate_destination,"000000000")
      assert_equal(AchClient::SiliconValleyBank.immediate_destination_name, "Test Destination")
      assert_equal(AchClient::SiliconValleyBank.immediate_origin, "000000000")
      assert_equal(AchClient::SiliconValleyBank.immediate_origin_name, "Test Origin")
      assert_equal(AchClient::SiliconValleyBank.company_identification, "123456789")
      assert_equal(AchClient::SiliconValleyBank.company_entry_description, "idk brah")
      assert_equal(AchClient::SiliconValleyBank.originating_dfi_identification, "00000000")

      AchClient::SiliconValleyBank.immediate_destination = nil
      AchClient::SiliconValleyBank.immediate_destination_name = nil
      AchClient::SiliconValleyBank.immediate_origin = nil
      AchClient::SiliconValleyBank.immediate_origin_name = nil
      AchClient::SiliconValleyBank.company_identification = nil
      AchClient::SiliconValleyBank.company_entry_description = nil
      AchClient::SiliconValleyBank.originating_dfi_identification = nil

      assert_equal(AchClient::SiliconValleyBank.immediate_destination, nil)
      assert_equal(AchClient::SiliconValleyBank.immediate_destination_name, nil)
      assert_equal(AchClient::SiliconValleyBank.immediate_origin, nil)
      assert_equal(AchClient::SiliconValleyBank.immediate_origin_name, nil)
      assert_equal(AchClient::SiliconValleyBank.company_identification, nil)
      assert_equal(AchClient::SiliconValleyBank.company_entry_description, nil)
      assert_equal(AchClient::SiliconValleyBank.originating_dfi_identification, nil)

      AchClient::SiliconValleyBank.immediate_destination = '000000000'
      AchClient::SiliconValleyBank.immediate_destination_name = 'Test Destination'
      AchClient::SiliconValleyBank.immediate_origin = '000000000'
      AchClient::SiliconValleyBank.immediate_origin_name = 'Test Origin'
      AchClient::SiliconValleyBank.company_identification = '123456789'
      AchClient::SiliconValleyBank.company_entry_description = 'idk brah'
      AchClient::SiliconValleyBank.originating_dfi_identification = '00000000'
    end
  end
end
