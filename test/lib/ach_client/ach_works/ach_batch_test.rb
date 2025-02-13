require 'test_helper'

class AchWorks
  class AchBatchTest < Minitest::Test
    def debit
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
      )
    end

    def credit
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
        transaction_type: AchClient::TransactionTypes::Credit,
        external_ach_id: 'foooo',
        customer_id: 'foo'
      )
    end

    def invalid
      AchClient::AchWorks::AchTransaction.new(
        account_number: '00002323044',
        account_type: AchClient::AccountTypes::Checking,
        amount: BigDecimal('575.45'),
        effective_entry_date: Date.today,
        memo: '????',
        merchant_name: 'DOE, JOHN',
        routing_number: nil,
        transaction_type: AchClient::TransactionTypes::Credit,
        external_ach_id: 'foooo'
      )
    end

    def transactions
      [
        credit,
        debit,
        debit,
        credit,
        credit,
        debit
      ]
    end

    def batch
      AchClient::AchWorks::AchBatch.new(
        ach_transactions: transactions
      )
    end

    def bad_batch
      AchClient::AchWorks::AchBatch.new(
        ach_transactions: transactions + [invalid]
      )
    end

    def awful_batch
      AchClient::AchWorks::AchBatch.new(
        ach_transactions: []
      )
    end

    def test_that_it_works
      VCR.use_cassette('send_batch') do
        # It returns the ACH filename
        response = batch.send_batch
        assert_equal(response, ["foooo", "foooo", "foooo", "foooo", "foooo", "foooo"])

        assert_requested(
          :post,
          'http://tstsvr.achworks.com/dnet/achws.asmx',
          headers: {
            'Content-Type' => 'text/xml;charset=UTF-8',
            'Soapaction' => '"http://achworks.com/SendACHTransBatch"'
          },
          times: 1
        )
      end
    end

    def test_that_it_has_the_right_hash
      assert_equal(
        batch.to_hash[:InpCompanyInfo],
        {
          SSS: 'TST',
          LocID: '9505',
          Company: 'MYCOMPANY',
          CompanyKey: 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD'
        }
      )
      assert_equal(batch.to_hash[:InpACHFile][:SSS], 'TST')
      assert_equal(batch.to_hash[:InpACHFile][:LocID], '9505')
      assert_nil(batch.to_hash[:InpACHFile][:ACHFileName])
      assert_equal(batch.to_hash[:InpACHFile][:TotalNumRecords], 6)
      assert_equal(batch.to_hash[:InpACHFile][:TotalDebitRecords], 3)
      assert_equal(
        batch.to_hash[:InpACHFile][:TotalDebitAmount],
        BigDecimal('575.45') * 3
      )
      assert_equal(batch.to_hash[:InpACHFile][:TotalCreditRecords], 3)
      assert_equal(
        batch.to_hash[:InpACHFile][:TotalCreditAmount],
        BigDecimal('575.45') * 3
      )
      assert_equal(
        batch.to_hash[:InpACHFile][:ACHRecords][:ACHTransRecord].length,
        6
      )
      expecteds = [
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
          CustomerAcctType: 'C',
          TransAmount: BigDecimal('575.45').to_s,
          CheckOrTransDate: '2016-08-11T00:00:00',
          EffectiveDate: '2016-08-11T00:00:00',
          Memo: '????',
          OpCode: 'S',
          AccountSet: '1'
        },
        {
          SSS: 'TST',
          LocID: '9505',
          FrontEndTrace: 'Zfoooo',
          CustomerName: 'DOE, JOHN',
          CustomerRoutingNo: '123456780',
          CustomerAcctNo: '00002323044',
          OriginatorName: 'ff',
          TransactionCode: 'CCD',
          CustTransType: 'D',
          CustomerID: 'foo',
          CustomerAcctType: 'C',
          TransAmount: BigDecimal('575.45').to_s,
          CheckOrTransDate: '2016-08-11T00:00:00',
          EffectiveDate: '2016-08-11T00:00:00',
          Memo: '????',
          OpCode: 'S',
          AccountSet: '1'
        }
      ]
      batch.to_hash[:InpACHFile][:ACHRecords][:ACHTransRecord].each do |hash|
        hash[:TransAmount] = hash[:TransAmount].to_s
        assert_includes(expecteds, hash)
      end
    end

    def test_send_bad_batch_raises_errors
      assert_raises(InvalidAchTransactionError) do
        invalid = credit
        invalid.instance_variable_set(:@effective_entry_date, Date.yesterday)
        AchClient::AchWorks::AchBatch.new(
          ach_transactions: [invalid]
        ).send_batch
      end
      VCR.use_cassette('send_invalid_batch') do
        assert_equal(
          assert_raises(RuntimeError) do
            bad_batch.send_batch
          end.message,
          'Error#1:Invalid CustomerRoutingNo, Rec#7, Error#2:Unable to complete processing of data due to error(s).'
        )
      end
    end

    def test_send_no_company_batch_raises_errors
      AchClient::AchWorks.stub(:company, nil) do
        VCR.use_cassette('send_no_company_batch') do
          assert_includes(
            assert_raises(RuntimeError) do
              AchClient::AchWorks::AchBatch.new(
                ach_transactions: [debit, credit]
              ).send_batch
            end.message,
            'Rejected due to invalid company information'
          )
        end
      end
    end

    def test_cause_dot_net_error_batch_raises_errors
      AchClient::AchWorks.stub(:s_s_s, {foo: :bar}) do
        VCR.use_cassette('send_dot_net_error') do
          assert_equal(
            assert_raises(RuntimeError) do
              AchClient::AchWorks::AchBatch.new(
                ach_transactions: [debit, debit]
              ).send_batch
            end.message,
            '(soap:Server) Server was unable to process request. ---> Object reference not set to an instance of an object.'
          )
        end
      end
    end

    class FakeUnsuccessfulResponse
      def success?
        false
      end
    end

    def test_unsuccessful_raises_errors
      batch = AchClient::AchWorks::AchBatch.new(
        ach_transactions: [credit, credit]
      )
      AchClient::AchWorks.stub(:request, FakeUnsuccessfulResponse.new) do
        assert_equal(
          assert_raises(RuntimeError) do
            batch.send_batch
          end.message,
          'send_ach_trans_batch failed due to unknown SOAP fault'
        )
      end
    end
  end
end
