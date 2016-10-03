require 'test_helper'

class AchClientTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AchClient::VERSION
  end

  def test_it_does_something_useful
    assert true
  end

  def test_magic
    assert(AchClient::MagicBank.include?(AchClient::SftpProvider))
    assert(AchClient::MagicBank.include?(AchClient::NachaProvider))
    assert(
      AchClient::MagicBank::AchTransaction < AchClient::Sftp::AchTransaction
    )
    assert(
      AchClient::MagicBank::AchBatch < AchClient::Sftp::AchBatch
    )
  end
end
