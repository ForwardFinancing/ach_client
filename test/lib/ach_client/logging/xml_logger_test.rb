require 'test_helper'

class LogProviderTest < Minitest::Test
  def test_abstractness
    assert_raises(AbstractMethodError) do
      AchClient::Logging::LogProvider.send_logs(
        body: 'foo',
        name: 'bar'
      )
    end
  end
end
