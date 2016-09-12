require 'test_helper'

class StdoutLogProviderTest < MiniTest::Test
  def test_that_it_works
    AchClient::Logging.stub(
      :log_provider,
      AchClient::Logging::StdoutLogProvider
    ) do
      VCR.use_cassette('logger') do
        output = capture_subprocess_io do
          AchClient::AchWorks.send(
            :request,
            method: :connection_check,
            message: AchClient::AchWorks::CompanyInfo.build.to_hash
          )
        end.first
        assert_includes(output, 'request-connection_check')
        assert_includes(output, 'response-AchWorks-connection_check')
        assert_includes(output, '.xml')
        assert_includes(output, '<?xml')
      end
    end
  end
end
