require 'test_helper'

class AchStatusChecker < MiniTest::Test
  def status_checker
    AchClient::AchWorks::AchStatusChecker.new(
      company_info: AchClient::AchWorks::InputCompanyInfo.build
    )
  end

  def test_most_recent_invalid_response_code
    VCR.use_cassette('most_recent_invalid') do
      assert_equal(
        assert_raises(RuntimeError) { status_checker.most_recent }.message,
        "Unknown response code FAKE"
      )
    end
  end

  def test_most_recent
    # Check out the vcr and take a look at the XML response that was returned
    # This is the data that is being processed and returned in the response
    # array. It matches production data, but account numbers, etc were scrubbed
    VCR.use_cassette('most_recent') do
      response = status_checker.most_recent

      assert(response['WRG-SCRUB0'].is_a?(AchClient::ReturnedAchResponse))
      assert(response['WRG-SCRUB0'].date.is_a?(DateTime))
      assert_equal(
        response['WRG-SCRUB0'].return_code,
        AchClient::ReturnCodes.find_by(code: 'R01')
      )

      assert(response['WRG-SCRUB1'].is_a?(AchClient::ProcessingAchResponse))
      assert(response['WRG-SCRUB1'].date.is_a?(DateTime))

      assert(response['WRG-SCRUB2'].is_a?(AchClient::SettledAchResponse))
      assert(response['WRG-SCRUB2'].date.is_a?(DateTime))

      assert(response['WRG-SCRUB3'].is_a?(AchClient::ReturnedAchResponse))
      assert(response['WRG-SCRUB3'].date.is_a?(DateTime))
      assert_equal(
        response['WRG-SCRUB3'].return_code,
        AchClient::ReturnCodes.find_by(code: 'R01')
      )

      assert(response['WRG-SCRUB4'].is_a?(AchClient::CorrectedAchResponse))
      assert(response['WRG-SCRUB4'].date.is_a?(DateTime))
      assert_equal(
        response['WRG-SCRUB4'].return_code,
        AchClient::ReturnCodes.find_by(code: 'C01')
      )
      assert_equal(
        response['WRG-SCRUB4'].corrections[:unhandled_correction_data],
        "2323044                      "
      )
      assert_includes(
        response['WRG-SCRUB4'].corrections[:note],
        "can't tell you what this data means"
      )

      assert(response['WRG-SCRUB5'].is_a?(AchClient::CorrectedAchResponse))
      assert(response['WRG-SCRUB5'].date.is_a?(DateTime))
      assert_equal(
        response['WRG-SCRUB5'].return_code,
        AchClient::ReturnCodes.find_by(code: 'C03')
      )
      assert_equal(
        response['WRG-SCRUB5'].corrections[:routing_number],
        "123456780"
      )
      assert_equal(
        response['WRG-SCRUB5'].corrections[:account_number],
        "30441234567802323"
      )

      assert(response['WRG-SCRUB6'].is_a?(AchClient::CorrectedAchResponse))
      assert(response['WRG-SCRUB6'].date.is_a?(DateTime))
      assert_equal(
        response['WRG-SCRUB6'].return_code,
        AchClient::ReturnCodes.find_by(code: 'C06')
      )
      assert_equal(
        response['WRG-SCRUB6'].corrections[:account_number],
        "000023230CC000023"
      )
      assert_equal(
        response['WRG-SCRUB6'].corrections[:account_type],
        AccountTypes::Checking
      )

      assert(response['WRG-SCRUB7'].is_a?(AchClient::CorrectedAchResponse))
      assert(response['WRG-SCRUB7'].date.is_a?(DateTime))
      assert_equal(
        response['WRG-SCRUB7'].return_code,
        AchClient::ReturnCodes.find_by(code: 'C07')
      )
      assert_equal(
        response['WRG-SCRUB7'].corrections[:routing_number],
        "000023230"
      )
      assert_equal(
        response['WRG-SCRUB7'].corrections[:account_type],
        AccountTypes::Checking
      )
      assert_equal(
        response['WRG-SCRUB7'].corrections[:account_number],
        "CC000023230CC888C"
      )

      # Ignores 9BNKs, which don't have front end traces
      refute(response.keys.include?(nil))
    end
  end

  def test_most_recent_empty
    VCR.use_cassette('most_recent_empty') do
      assert_equal(status_checker.most_recent, [])
      assert_requested(
        :post,
        'http://tstsvr.achworks.com/dnet/achws.asmx',
        headers: {
          'Content-Type' => 'text/xml;charset=UTF-8',
          'Soapaction' => '"http://achworks.com/GetACHReturns"'
        },
        times: 1
      )
    end
  end

  def test_in_range_empty
    VCR.use_cassette('in_range_empty') do
      assert_equal(
        status_checker.in_range(
          start_date: 1.week.ago,
          end_date: Date.today
        ),
        []
      )

      assert_requested(
        :post,
        'http://tstsvr.achworks.com/dnet/achws.asmx',
        headers: {
          'Content-Type' => 'text/xml;charset=UTF-8',
          'Soapaction' => '"http://achworks.com/GetACHReturnsHist"'
        },
        times: 1
      )
    end
  end

  def test_most_recent_hash
    assert_equal(
      status_checker.send(:most_recent_hash),
      {
        InpCompanyInfo: {
          Company: 'MYCOMPANY',
          CompanyKey: 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD',
          LocID: '9505',
          SSS: 'TST'
        }
      }
    )
  end

  def test_in_range_hash
    assert_equal(
      status_checker.send(
        :in_range_hash,
        start_date: Date.yesterday,
        end_date: Date.today
      ),
      {
        InpCompanyInfo: {
          Company: 'MYCOMPANY',
          CompanyKey: 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD',
          LocID: '9505',
          SSS: 'TST'
        },
        ReturnDateFrom: '2016-08-10T00:00:00.00000+00:00',
        ReturnDateTo: '2016-08-11T00:00:00.00000+00:00'
      }
    )
  end
end
