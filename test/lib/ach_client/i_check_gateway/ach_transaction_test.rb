require 'test_helper'
class ICheckGateway
  class AchTransactionTest < MiniTest::Test
    def transaction
      AchClient::ICheckGateway::AchTransaction.new(
        account_number: '115654668777',
        account_type: AchClient::AccountTypes::BusinessChecking,
        amount: BigDecimal('575.45'),
        effective_entry_date: Date.today,
        memo: '????',
        merchant_name: 'test merchant',
        originator_name: 'ff',
        routing_number: '083000108',
        sec_code: 'CCD',
        transaction_type: AchClient::TransactionTypes::Debit
      )
    end

    def test_to_hash
      assert_equal(
        transaction.to_hash,
        {
          APIMethod: 'ProcessCheck',
          SiteID: 'SEDZ',
          SiteKey: '236652',
          APIKey: 'a3GFMBGz6KhkTzg',
          Amount: BigDecimal('575.45'),
          RoutingNumber: '083000108',
          AccountNumber: '115654668777',
          AccountType: 'BC',
          EntryClassCode: 'CCD',
          GatewayLiveMode: '0',
          TransactionType: 'D',
          CompanyName: 'test merchant',
          Description: '????',
          TransactionDate: Date.today
        }
      )
    end

    def test_successful_send
      Date.stub(:today, 100.years.from_now.to_date) do
        VCR.use_cassette('icheckgateway_ach_transaction_success') do
          assert_equal(
            transaction.send,
            '40835ba3b09c'
          )
        end
      end
    end

    def test_failure_send
      assert_raises(InvalidAchTransactionError) do
        invalid_transaction = transaction
        invalid_transaction.instance_variable_set(
          :@effective_entry_date,
          Date.yesterday
        )
        invalid_transaction.send
      end
      # Request will fail because `Date.today` is in the past
      VCR.use_cassette('icheckgateway_ach_transaction_failure') do
        assert_equal(
          assert_raises(RuntimeError) { transaction.send }.message,
          'ICheckGateway ACH Transaction Failure: ERROR: PaymentDate Must Be a Present of Future Date -'
        )
      end
    end

    def test_failure_correction
      error = assert_raises(AchClient::ICheckGateway::InstantRejectionError) do
        VCR.use_cassette('icheckgateway_ach_transaction_correction') do
          transaction.send
        end
      end
      assert_equal(error.ach_response.amount, transaction.amount)
      assert_equal(error.ach_response.corrections, "987654321")
      assert_equal(error.ach_response.date, transaction.effective_entry_date)
      assert_equal(error.ach_response.return_code.code, 'XZ2')
    end

    def test_failure_x13
      error = assert_raises(AchClient::ICheckGateway::InstantRejectionError) do
        VCR.use_cassette('icheckgateway_ach_transaction_x13') do
          transaction.send
        end
      end
      assert_equal(error.ach_response.amount, transaction.amount)
      assert_equal(error.ach_response.date, transaction.effective_entry_date)
      assert_equal(error.ach_response.return_code.code, 'X13')
    end

    class FakeUnsuccessfulResponse
      def success?
        false
      end
    end

    def test_fault_send
      AchClient::ICheckGateway.stub(:request, FakeUnsuccessfulResponse.new) do
        VCR.use_cassette('icheckgateway_ach_transaction_fault') do
          assert_equal(
            assert_raises(RuntimeError) { transaction.send }.message,
            'Unknown ICheckGateway SOAP fault'
          )
        end
      end
    end
  end
end
