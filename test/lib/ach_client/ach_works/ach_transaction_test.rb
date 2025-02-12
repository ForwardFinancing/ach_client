require 'test_helper'

class AchWorks
  class AchTransactionTest < Minitest::Test
    def test_that_it_works
      assert_equal(
        AchClient::AchWorks::AchTransaction.new(
          account_number: '00002323044',
          account_type: AchClient::AccountTypes::Checking,
          amount: BigDecimal('575.45'),
          effective_entry_date: Date.today,
          memo: '????',
          merchant_name: 'DOE, JOHN MELONCAMP FALLON DOUGIE',
          originator_name: 'ff',
          routing_number: '123456780',
          sec_code: 'CCD',
          transaction_type: AchClient::TransactionTypes::Debit,
          external_ach_id: 'foooo',
          customer_id: 'foo'
        ).to_hash,
        {
          SSS: 'TST',
          LocID: '9505',
          FrontEndTrace: 'Zfoooo',
          CustomerName: 'DOE, JOHN MELONCAMP FA',
          CustomerRoutingNo: '123456780',
          CustomerAcctNo: '00002323044',
          OriginatorName: 'ff',
          TransactionCode: 'CCD',
          CustTransType: 'D',
          CustomerID: 'foo',
          CustomerAcctType: 'C',
          TransAmount: 575.45,
          CheckOrTransDate: '2016-08-11T00:00:00.00000+00:00',
          EffectiveDate: '2016-08-11T00:00:00.00000+00:00',
          Memo: '????',
          OpCode: 'S',
          AccountSet: '1'
        }
      )

      assert_equal(
        AchClient::AchWorks::AchTransaction.new(
          account_number: '00002323044',
          account_type: AchClient::AccountTypes::Savings,
          amount: BigDecimal('575.45'),
          effective_entry_date: Date.today,
          memo: '????',
          merchant_name: 'DOE, JOHN',
          originator_name: 'ff',
          sec_code: 'CCD',
          routing_number: '123456780',
          transaction_type: AchClient::TransactionTypes::Credit,
          external_ach_id: 'foooo',
          customer_id: 'foo'
        ).to_hash,
        {
          SSS: 'TST',
          LocID: '9505',
          FrontEndTrace: 'Zfoooo',
          CustomerName: 'DOE, JOHN',
          CustomerRoutingNo: '123456780',
          CustomerAcctNo: '00002323044',
          OriginatorName: 'ff',
          TransactionCode: 'CCD',
          CustTransType: 'C',
          CustomerID: 'foo',
          CustomerAcctType: 'S',
          TransAmount: 575.45,
          CheckOrTransDate: '2016-08-11T00:00:00.00000+00:00',
          EffectiveDate: '2016-08-11T00:00:00.00000+00:00',
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
          account_type: AchClient::AccountTypes::Savings,
          amount: 575.45,
          effective_entry_date: Date.today,
          memo: '????',
          merchant_name: 'DOE, JOHN',
          routing_number: '123456780',
          transaction_type: AchClient::TransactionTypes::Credit,
          external_ach_id: '123456789012' # too long
        ).to_hash
      end

      assert_raises(RuntimeError) do
        AchClient::AchWorks::AchTransaction.new(
          account_number: '00002323044',
          account_type: String, #invalid
          amount: 575.45,
          effective_entry_date: Date.today,
          memo: '????',
          merchant_name: 'DOE, JOHN',
          routing_number: '123456780',
          transaction_type: AchClient::TransactionTypes::Credit,
          external_ach_id: 'foo'
        ).to_hash
      end

      assert_raises(RuntimeError) do
        AchClient::AchWorks::AchTransaction.new(
          account_number: '00002323044',
          account_type: AchClient::AccountTypes::Savings,
          amount: 575.45,
          effective_entry_date: Date.today,
          memo: '????',
          merchant_name: 'DOE, JOHN',
          routing_number: '123456780',
          transaction_type: BigDecimal, #invalid
          external_ach_id: 'foo'
        ).to_hash
      end
    end

    def test_send
      assert_raises(InvalidAchTransactionError) do
        AchClient::AchWorks::AchTransaction.new(
          account_number: '00002323044',
          account_type: AchClient::AccountTypes::Checking,
          amount: BigDecimal('575.45'),
          effective_entry_date: Date.yesterday,
          memo: '????',
          merchant_name: 'DOE, JOHN',
          originator_name: 'ff',
          routing_number: '123456780',
          sec_code: 'CCD',
          transaction_type: AchClient::TransactionTypes::Debit,
          external_ach_id: 'foooo',
          customer_id: 'foo'
        ).send
      end
      VCR.use_cassette('ach_works_ach_transaction_success') do
        assert_equal(
          AchClient::AchWorks::AchTransaction.new(
            account_number: '00002323044',
            account_type: AchClient::AccountTypes::Checking,
            amount: BigDecimal('575.45'),
            effective_entry_date: Date.today,
            memo: '????',
            merchant_name: 'DOE, JOHN',
            originator_name: 'ff',
            routing_number: '123456780',
            sec_code: 'CCD',
            transaction_type: AchClient::TransactionTypes::Debit,
            external_ach_id: 'foooo',
            customer_id: 'foo'
          ).send,
          'foooo'
        )
      end
    end
  end
end
