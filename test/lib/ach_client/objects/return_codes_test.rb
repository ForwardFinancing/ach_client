require 'test_helper'

class ReturnCodesTest < Minitest::Test
  def test_unauthorized
    unauthorized_codes = AchClient::ReturnCodes.unauthorized
    assert(unauthorized_codes.all?(&:unauthorized_return?))
  end

  def test_administrative
    administrative_codes = AchClient::ReturnCodes.administrative
    assert(administrative_codes.all?(&:administrative_return?))
  end
end
