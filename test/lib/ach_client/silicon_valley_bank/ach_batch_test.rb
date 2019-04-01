require 'test_helper'

class SiliconValleyBank
  class AchBatchTest < MiniTest::Test
    def transaction
      AchClient::SiliconValleyBank::AchTransaction.new(
        account_number: '00002323044',
        account_type: AchClient::AccountTypes::Checking,
        amount: BigDecimal.new('575.45'),
        effective_entry_date: Date.today,
        memo: '????',
        merchant_name: "DOE,\n JOHN\r\n",
        originator_name: 'ff',
        routing_number: '123456780',
        sec_code: 'CCD',
        transaction_type: AchClient::TransactionTypes::Debit,
        external_ach_id: '123foooo',
        customer_id: 'foo'
      )
    end

    def batch
      AchClient::SiliconValleyBank::AchBatch.new(
        ach_transactions: [transaction, transaction]
      )
    end


    def expected_batch_result
      "101 000000000 0000000001608111013A094101TEST DESTINATION       TEST ORIGIN                    \r\n5225FF                                  1123456789CCDIDK BRAH  160811160811   1000000000000001\r\n62712345678000002323044      0000057545123FOOOO       DOE, JOHN               0000000000000123\r\n62712345678000002323044      0000057545123FOOOO       DOE, JOHN               0000000000000123\r\n822500000200246913560000001150900000000000001123456789                         000000000000001\r\n9000001000001000000020024691356000000115090000000000000                                       \r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999\r\n"
    end


    def test_send_batch
      Net::SFTP.stubs(:start).yields(FakeSFTPConnection)
      AchClient::Logging.stub(
        :log_provider,
        AchClient::Logging::StdoutLogProvider
      ) do
        log_output = capture_subprocess_io do
          assert_equal(batch.send_batch, ["123foooo", "123foooo"])
        end.first
        # Make sure logging happened too
        assert_equal(
          "request-2016-08-11T10:13:05-04:00-root-svb_sandbox-inbox-achp08111601\n#{expected_batch_result}",
          log_output
        )
      end
    end

    def test_nacha
      assert_equal(batch.cook_some_nachas.to_s, expected_batch_result)
    end

    def test_send_invalid_batch
      assert_raises(InvalidAchTransactionError) do
        invalid = transaction
        invalid.instance_variable_set(:@effective_entry_date, Date.yesterday)
        AchClient::SiliconValleyBank::AchBatch.new(
          ach_transactions: [invalid]
        ).send_batch
      end
    end
  end
end
