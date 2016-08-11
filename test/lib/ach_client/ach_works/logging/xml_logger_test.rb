require 'test_helper'

class LogProviderTest < MiniTest::Test
  def test_abstractness
    assert_raises(AbstractMethodError) do
      AchClient::AchWorks::Logging::LogProvider.send_logs(
        body: 'foo',
        name: 'bar'
      )
    end
  end
end
