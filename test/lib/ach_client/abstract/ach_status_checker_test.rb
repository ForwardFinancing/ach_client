require 'test_helper'

class Abstract
  class AchStatusCheckerTest < Minitest::Test
    def test_abstractlyness
      assert_raises(AbstractMethodError) do
        AchClient::Abstract::AchStatusChecker.most_recent
      end
      assert_raises(AbstractMethodError) do
        AchClient::Abstract::AchStatusChecker.in_range(
          start_date: 'foo',
          end_date: 'foo'
        )
      end
    end
  end
end
