require 'test_helper'

class LoggingTest < Minitest::Test
  def test_log_provider_assignment
    assert_equal(
      AchClient::Logging.log_provider,
      AchClient::Logging::NullLogProvider
    )

    AchClient::Logging.log_provider = AchClient::Logging::StdoutLogProvider

    assert_equal(
      AchClient::Logging.log_provider,
      AchClient::Logging::StdoutLogProvider
    )

    assert_raises(RuntimeError) {AchClient::Logging.log_provider = ''}
    AchClient::Logging.log_provider = AchClient::Logging::NullLogProvider
  end

  def test_log_filter_assignment
    assert_equal(AchClient::Logging.log_filters, [])

    AchClient::Logging.log_filters = ['Something']

    assert_equal(AchClient::Logging.log_filters, ['Something'])

    AchClient::Logging.log_filters = nil

    assert_equal(AchClient::Logging.log_filters, [])
  end

  def log_output
    output = capture_subprocess_io do
      VCR.use_cassette('logger') do
        AchClient::AchWorks.send(:soap_client).call(
          :connection_check,
          message: AchClient::AchWorks::CompanyInfo.build.to_hash
        )
      end
    end.first
  end

  def test_log_scrubbing
    AchClient::Logging.stub(
      :log_provider,
      AchClient::Logging::StdoutLogProvider
    ) do
      AchClient::Logging.stub(:log_filters, ['CompanyKey']) do
        output = log_output
        assert(output.include?('***FILTERED***'))
        refute(output.include?(AchClient::AchWorks.company_key))
      end
    end
  end

  def log_output
    output = ''
    VCR.use_cassette('logger') do
      output = capture_subprocess_io do
        AchClient::AchWorks.send(:soap_client).call(
          :connection_check,
          message: AchClient::AchWorks::CompanyInfo.build.to_hash
        )
      end.first
    end
    output
  end

  def test_codec
    AchClient::Logging.stub(:encryption_password, 'password') do
      AchClient::Logging.stub(:encryption_salt, 'pepper') do
        message = "Super secret secrets"
        log_encrypted = AchClient::Logging.codec.encrypt_and_sign(message)
        encrypted = ActiveSupport::MessageEncryptor.new(
          ActiveSupport::KeyGenerator.new('password').generate_key('pepper', 32)
        ).encrypt_and_sign(message)

        log_decrypted = AchClient::Logging.decrypt_log(log_encrypted)
        decrypted = ActiveSupport::MessageEncryptor.new(
          ActiveSupport::KeyGenerator.new('password').generate_key('pepper', 32)
        ).decrypt_and_verify(log_encrypted)

        assert_equal(log_decrypted, decrypted)
        assert_equal(log_decrypted, message)
        assert_equal(decrypted, message)
      end
    end
  end

  def test_log_encryption
    AchClient::Logging.stub(
      :log_provider,
      AchClient::Logging::StdoutLogProvider
    ) do
      plain_output = log_output
      AchClient::Logging.stub(:encryption_password, 'password') do
        AchClient::Logging.stub(:encryption_salt, 'pepper') do
          decrypted_output = ActiveSupport::MessageEncryptor.new(
            ActiveSupport::KeyGenerator.new('password').generate_key('pepper', 32)
          ).decrypt_and_verify(log_output.split("\n")[1])
          assert_equal(
            plain_output.split("\n")[1..-1].join("\n") + "\n",
            decrypted_output
          )
        end
      end
    end
  end
end
