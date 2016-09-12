require 'test_helper'

class CompanyInfoTest < MiniTest::Test
  def test_abstractlyness
    assert_raises(AbstractMethodError) do
      AchClient::Abstract::CompanyInfo.build
    end

    assert_raises(AbstractMethodError) do
      AchClient::Abstract::CompanyInfo.new.to_hash
    end
  end
end
