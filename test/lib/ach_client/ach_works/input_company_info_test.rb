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
end
