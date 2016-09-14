require 'test_helper'

class AchTransactionTest < MiniTest::Test
  def svb_transaction
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
      'SiliconValleyBank does not support individual transactions'
    )
  end
end
