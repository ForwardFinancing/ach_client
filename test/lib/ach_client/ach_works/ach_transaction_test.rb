require 'test_helper'

class AchTransactionTest < MiniTest::Test
  def test_that_it_works
    assert_equal(
      AchClient::AchWorks::AchTransaction.new(
        account_number: '00002323044',
        account_type: AccountTypes::Checking,
        amount: BigDecimal.new('575.45'),
        memo: '????',
        merchant_name: 'DOE, JOHN',
        routing_number: '123456780',
        transaction_type: TransactionTypes::Debit,
        ach_id: 'foooo'
      ).to_hash,
      {
        SSS: 'TST',
        LocID: '9505',
        FrontEndTrace: 'Zfoooo',
        CustomerName: 'DOE, JOHN',
        CustomerRoutingNo: '123456780',
        CustomerAcctNo: '00002323044',
        OriginatorName: 'TBD',
        TransactionCode: 'WEB',
        CustTransType: 'D',
        CustomerID: 'TBD',
        CustomerAcctType: 'C',
        TransAmount: 575.45,
        CheckOrTransDate: Date.today,
        EffectiveDate: Date.today,
        Memo: '????',
        OpCode: 'S',
        AccountSet: '1'
      }
    )

    assert_equal(
      AchClient::AchWorks::AchTransaction.new(
        account_number: '00002323044',
        account_type: AccountTypes::Savings,
        amount: BigDecimal.new('575.45'),
        memo: '????',
        merchant_name: 'DOE, JOHN',
        routing_number: '123456780',
        transaction_type: TransactionTypes::Credit,
        ach_id: 'foooo'
      ).to_hash,
      {
        SSS: 'TST',
        LocID: '9505',
        FrontEndTrace: 'Zfoooo',
        CustomerName: 'DOE, JOHN',
        CustomerRoutingNo: '123456780',
        CustomerAcctNo: '00002323044',
        OriginatorName: 'TBD',
        TransactionCode: 'WEB',
        CustTransType: 'C',
        CustomerID: 'TBD',
        CustomerAcctType: 'S',
        TransAmount: 575.45,
        CheckOrTransDate: Date.today,
        EffectiveDate: Date.today,
        Memo: '????',
        OpCode: 'S',
        AccountSet: '1'
      }
    )
  end

  def test_that_it_doesnt_work_with_invalid_args
    assert_raises(RuntimeError) do
      AchClient::AchWorks::AchTransaction.new(
        account_number: '00002323044',
        account_type: AccountTypes::Savings,
        amount: 575.45,
        memo: '????',
        merchant_name: 'DOE, JOHN',
        routing_number: '123456780',
        transaction_type: TransactionTypes::Credit,
        ach_id: '123456789012' # too long
      ).to_hash
    end

    assert_raises(RuntimeError) do
      AchClient::AchWorks::AchTransaction.new(
        account_number: '00002323044',
        account_type: String, #invalid
        amount: 575.45,
        memo: '????',
        merchant_name: 'DOE, JOHN',
        routing_number: '123456780',
        transaction_type: TransactionTypes::Credit,
        ach_id: 'foo'
      ).to_hash
    end

    assert_raises(RuntimeError) do
      AchClient::AchWorks::AchTransaction.new(
        account_number: '00002323044',
        account_type: AccountTypes::Savings,
        amount: 575.45,
        memo: '????',
        merchant_name: 'DOE, JOHN',
        routing_number: '123456780',
        transaction_type: BigDecimal, #invalid
        ach_id: 'foo'
      ).to_hash
    end
  end
end
