require 'test_helper'

class StdoutLogProviderTest < MiniTest::Test
  def test_that_it_works
    AchClient::AchWorks::Logging.stub(
      :log_provider,
      AchClient::AchWorks::Logging::StdoutLogProvider
    ) do
      VCR.use_cassette('logger') do
        output = capture_subprocess_io do
          AchClient::AchWorks.send(
            :request,
            method: :connection_check,
            message: AchClient::AchWorks::InputCompanyInfo.build.to_hash
          )
        end.first
        assert_includes(output, 'request-connection_check')
        assert_includes(output, 'response-connection_check')
        assert_includes(output, '.xml')
        assert_includes(output, '<?xml')
      end
    end
  end
end