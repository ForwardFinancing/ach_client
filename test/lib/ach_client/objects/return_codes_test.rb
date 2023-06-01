require 'test_helper'

class ReturnCodesTest < MiniTest::Test
  def test_unauthorized
    unauthorized_codes = AchClient::ReturnCodes.unauthorized
    assert(unauthorized_codes.all?{|code| code.unauthorized_return?})
  end

  def test_administrative
    administrative_codes = AchClient::ReturnCodes.administrative
    assert(administrative_codes.all?{|code| code.administrative_return?})
  end
end
