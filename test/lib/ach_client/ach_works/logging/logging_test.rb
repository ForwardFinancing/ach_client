require 'test_helper'

class LoggingTest < MiniTest::Test
  def test_log_provider_assignment
    assert_equal(
      AchClient::AchWorks::Logging.log_provider,
      AchClient::AchWorks::Logging::NullLogProvider
    )

    AchClient::AchWorks::Logging.log_provider = AchClient::AchWorks::Logging::StdoutLogProvider

    assert_equal(
      AchClient::AchWorks::Logging.log_provider,
      AchClient::AchWorks::Logging::StdoutLogProvider
    )

    assert_raises(RuntimeError) {AchClient::AchWorks::Logging.log_provider = ''}
    AchClient::AchWorks::Logging.log_provider = AchClient::AchWorks::Logging::NullLogProvider
  end
end
