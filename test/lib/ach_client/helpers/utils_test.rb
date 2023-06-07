require 'test_helper'

class UtilsTest < MiniTest::Test
  def test_icheck_date_format
    assert_equal(
      "wonky/date/format",
      AchClient::Helpers::Utils.icheck_date_format('wonky/date/format')
    )
    assert_raises do
      AchClient::Helpers::Utils.icheck_date_format(1)
    end
    refute(
      AchClient::Helpers::Utils.icheck_date_format(nil)
    )
  end
end
