require 'test_helper'

class AchWorks
  class DateFormatterTest < Minitest::Test
    def test_that_it_works
      assert_equal(
        AchClient::AchWorks::DateFormatter.format("2016-08-11"),
        '2016-08-11T00:00:00.00000+00:00'
      )
      assert_equal(
        AchClient::AchWorks::DateFormatter.format(Date.parse("2016-08-11")),
        '2016-08-11T00:00:00.00000+00:00'
      )
      assert_equal(
        AchClient::AchWorks::DateFormatter.format(
          DateTime.parse('2016-08-11T10:13:05-04:00')
        ),
        '2016-08-11T10:13:05.00000-04:00'
      )
      assert_raises(RuntimeError) {AchClient::AchWorks::DateFormatter.format(nil)}
    end
  end
end
