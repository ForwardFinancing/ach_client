require 'test_helper'
class Abstract
  class CompanyInfoTest < Minitest::Test
    def test_abstractlyness
      assert_raises(AbstractMethodError) do
        AchClient::Abstract::CompanyInfo.build
      end

      assert_raises(AbstractMethodError) do
        AchClient::Abstract::CompanyInfo.new.to_hash
      end
    end
  end
end
