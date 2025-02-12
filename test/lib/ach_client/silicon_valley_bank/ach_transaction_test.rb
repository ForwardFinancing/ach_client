require 'test_helper'
class SiliconValleyBank
  class AchTransactionTest < Minitest::Test
    def svb_transaction
      AchClient::SiliconValleyBank::AchTransaction.new(
        account_number: '00002323044',
        account_type: AchClient::AccountTypes::Checking,
        amount: BigDecimal('575.45'),
        memo: '????',
        merchant_name: 'DOE, JOHN',
        originator_name: 'ff',
        routing_number: '123456780',
        sec_code: 'CCD',
        transaction_type: AchClient::TransactionTypes::Debit,
        external_ach_id: '123foooo',
        effective_entry_date: Date.tomorrow,
        customer_id: 'foo'
      )
    end

    def test_that_it_works
      entry = ACH::EntryDetail.new
      entry.transaction_code = ACH::CHECKING_DEBIT
      entry.routing_number = '123456780'
      entry.account_number = '00002323044'
      entry.amount = 57545
      entry.individual_id_number = '123foooo'
      entry.individual_name = 'DOE, JOHN'
      entry.originating_dfi_identification = '00000000'
      entry.trace_number = 123
      assert_equal(svb_transaction.to_entry_detail.to_json, entry.to_json)
    end

    def test_send_abstract
      assert_equal(
        assert_raises(RuntimeError) do
          svb_transaction.send
        end.message,
        'NACHA/SFTP providers do not support individual transactions'
      )
    end

    def test_swaps_negative_debit_to_positive_credit
      entry = AchClient::SiliconValleyBank::AchTransaction.new(
        account_number: '00002323044',
        account_type: AchClient::AccountTypes::Checking,
        amount: BigDecimal('-575.45'),
        memo: '????',
        merchant_name: 'DOE, JOHN',
        originator_name: 'ff',
        routing_number: '123456780',
        sec_code: 'CCD',
        transaction_type: AchClient::TransactionTypes::Debit,
        external_ach_id: '123foooo',
        customer_id: 'foo'
      ).to_entry_detail
      refute(entry.debit?)
      assert(entry.amount.positive?)
    end

    def test_swaps_negative_credit_to_positive_debit
      entry = AchClient::SiliconValleyBank::AchTransaction.new(
        account_number: '00002323044',
        account_type: AchClient::AccountTypes::Checking,
        amount: BigDecimal('-575.45'),
        memo: '????',
        merchant_name: 'DOE, JOHN',
        originator_name: 'ff',
        routing_number: '123456780',
        sec_code: 'CCD',
        transaction_type: AchClient::TransactionTypes::Credit,
        external_ach_id: '123foooo',
        customer_id: 'foo'
      ).to_entry_detail
      refute(entry.credit?)
      assert(entry.amount.positive?)
    end
  end
end
