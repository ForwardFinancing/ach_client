require 'test_helper'

class InputCompanyInfoTest < Minitest::Test
  def test_that_it_works
    assert_equal(
      AchClient::AchWorks::InputCompanyInfo.build.to_hash,
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

  def test_connection_valid
    VCR.use_cassette('connection_valid') do
      assert(AchClient::AchWorks::InputCompanyInfo.build.connection_valid?)
    end
  end

  def test_company_valid
    VCR.use_cassette('company_valid') do
      assert(AchClient::AchWorks::InputCompanyInfo.build.company_valid?)
    end
  end

  def test_that_connection_check_works
    VCR.use_cassette('company_valid') do
      VCR.use_cassette('connection_valid') do
        assert(AchClient::AchWorks::InputCompanyInfo.build.valid?)
      end
    end
  end
end
