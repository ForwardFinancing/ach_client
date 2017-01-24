require 'test_helper'

class Objects
  class ReturnCodeTest < MiniTest::Test
    def test_correction?
      assert(AchClient::ReturnCodes.find_by(code: 'C01').correction?)
      refute(AchClient::ReturnCodes.find_by(code: 'R01').correction?)
    end

    def test_internal?
      assert(AchClient::ReturnCodes.find_by(code: 'X02').internal?)
      refute(AchClient::ReturnCodes.find_by(code: 'R01').internal?)
    end
  end
end
