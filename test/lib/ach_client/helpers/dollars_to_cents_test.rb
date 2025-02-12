require 'test_helper'

class DollarsToCentsTest < Minitest::Test
  def test_dollars_to_cents
    assert_equal(
      AchClient::Helpers::DollarsToCents.dollars_to_cents(1),
      100
    )
    assert_equal(
      AchClient::Helpers::DollarsToCents.dollars_to_cents(1.0),
      100
    )
    assert_equal(
      AchClient::Helpers::DollarsToCents.dollars_to_cents(1.01),
      101
    )
    assert_equal(
      AchClient::Helpers::DollarsToCents.dollars_to_cents(1.011),
      101
    )
    assert_equal(
      AchClient::Helpers::DollarsToCents.dollars_to_cents(1.016),
      102
    )
  end
end
