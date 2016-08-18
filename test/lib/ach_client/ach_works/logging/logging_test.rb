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

  def test_log_filter_assignment
    assert_equal(AchClient::AchWorks::Logging.log_filters, [])

    AchClient::AchWorks::Logging.log_filters = ['Something']

    assert_equal(AchClient::AchWorks::Logging.log_filters, ['Something'])

    AchClient::AchWorks::Logging.log_filters = nil

    assert_equal(AchClient::AchWorks::Logging.log_filters, [])
  end

  def test_log_scrubbing
    AchClient::AchWorks::Logging.stub(
      :log_provider,
      AchClient::AchWorks::Logging::StdoutLogProvider
    ) do
      AchClient::AchWorks::Logging.stub(:log_filters, ['CompanyKey']) do
        VCR.use_cassette('logger') do
          output = capture_subprocess_io do
            AchClient::AchWorks.send(:soap_client).call(
              :connection_check,
              message: AchClient::AchWorks::InputCompanyInfo.build.to_hash
            )
          end.first
          assert(output.include?('***FILTERED***'))
          refute(output.include?(AchClient::AchWorks.company_key))
        end
      end
    end
  end
end
