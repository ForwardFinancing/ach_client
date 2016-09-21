require 'test_helper'

class SiliconValleyBank
  class AchBatchTest < MiniTest::Test
    def transaction
      AchClient::SiliconValleyBank::AchTransaction.new(
        account_number: '00002323044',
        account_type: AchClient::AccountTypes::Checking,
        amount: BigDecimal.new('575.45'),
        memo: '????',
        merchant_name: 'DOE, JOHN',
        originator_name: 'ff',
        routing_number: '123456780',
        sec_code: 'CCD',
        transaction_type: AchClient::TransactionTypes::Debit,
        trace_id: '123foooo',
        customer_id: 'foo'
      )
    end

    def batch
      AchClient::SiliconValleyBank::AchBatch.new(
        ach_transactions: [transaction, transaction]
      )
    end


    def test_send_batch
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      assert_equal(batch.send_batch, 'ACHP08111606')
    end

    def test_nacha
      assert_equal(
        batch.cook_some_nachas.to_s,
        "101 000000000 0000000001608111013A094101TEST DESTINATION       TEST ORIGIN                    \r\n5225FF                                  1123456789CCDIDK BRAH  160811160811   1000000000000001\r\n62712345678000002323044      0000057545123FOOOO       DOE, JOHN               0000000000000123\r\n62712345678000002323044      0000057545123FOOOO       DOE, JOHN               0000000000000123\r\n822500000200246913560000001150900000000000001123456789                         000000000000001\r\n9000001000001000000020024691356000000115090000000000000                                       \r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n"
      )
    end
  end
end
