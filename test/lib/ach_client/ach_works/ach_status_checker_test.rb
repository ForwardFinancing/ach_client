require 'test_helper'

class AchStatusChecker < MiniTest::Test
  def status_checker
    AchClient::AchWorks::AchStatusChecker.new(
      company_info: AchClient::AchWorks::InputCompanyInfo.build
    )
  end

  def test_most_recent
    VCR.use_cassette('most_recent') do
      assert_equal(
        status_checker.most_recent.body[:get_ach_returns_response][:get_ach_returns_result][:status],
        'SUCCESS'
      )

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

  def test_in_range
    VCR.use_cassette('in_range') do
      assert_equal(
        status_checker.in_range(
          start_date: 1.week.ago,
          end_date: Date.today
        ).body[:get_ach_returns_hist_response][:get_ach_returns_hist_result][:status],
        'SUCCESS'
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
