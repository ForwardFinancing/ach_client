require_relative './fake_sftp_connection.rb'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'codeclimate-test-reporter'
SimpleCov.minimum_coverage 100
SimpleCov.start do
  add_filter '/test'
end

# Freeze time so we don't have to worry about Time.now relativity
require 'timecop'
Timecop.freeze(DateTime.parse('2016-08-11T10:13:05-04:00'))

# Everything happens synchronously
require 'sucker_punch/testing/inline'

require 'ach_client'
require 'ostruct'
require 'minitest/autorun'
require 'minitest/mock'
require 'mocha/minitest'
require 'pry'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require "minitest/reporters"
Minitest::Reporters.use!

# Configure test settings
AchClient::AchWorks.company_key = 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD'
AchClient::AchWorks.company = 'MYCOMPANY'
AchClient::AchWorks.loc_i_d = '9505'
AchClient::AchWorks.s_s_s = 'TST'
AchClient::AchWorks.wsdl = 'http://tstsvr.achworks.com/dnet/achws.asmx?wsdl'
AchClient::ICheckGateway.site_i_d = 'SEDZ'
AchClient::ICheckGateway.site_key = '236652'
AchClient::ICheckGateway.api_key = 'a3GFMBGz6KhkTzg'
AchClient::ICheckGateway.live = false
AchClient::ICheckGateway.wsdl = 'https://icheckgateway.com/API/Service.asmx?WSDL'
AchClient::SiliconValleyBank.immediate_destination = '000000000'
AchClient::SiliconValleyBank.immediate_destination_name = 'Test Destination'
AchClient::SiliconValleyBank.immediate_origin = '000000000'
AchClient::SiliconValleyBank.immediate_origin_name = 'Test Origin'
AchClient::SiliconValleyBank.company_identification = '123456789'
AchClient::SiliconValleyBank.company_entry_description = 'idk brah'
AchClient::SiliconValleyBank.originating_dfi_identification = '00000000'
AchClient::SiliconValleyBank.host = 'localhost:3000'
AchClient::SiliconValleyBank.username = 'ebachman@piedpiper.org'
AchClient::SiliconValleyBank.password = 'AviatoRulez7'
AchClient::SiliconValleyBank.private_ssh_key = "-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----"
AchClient::SiliconValleyBank.outgoing_path = '/root/svb_sandbox'
AchClient::SiliconValleyBank.outgoing_path = '/root/svb_sandbox/Inbox'
AchClient::SiliconValleyBank.file_naming_strategy = lambda do |batch_number|
  batch_number ||= 1
  "ACHP#{Date.today.strftime('%m%d%y')}#{batch_number.to_s.rjust(2, '0')}"
end

require 'webmock/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcrs'
  config.hook_into :webmock
  config.ignore_hosts 'codeclimate.com'
end

# Savon makes a request for the WSDL and caches it when the first request is
# made. We do this here in a VCR so that a future test is not the first request.
VCR.use_cassette 'ach_works-wsdl' do
  AchClient::AchWorks.send(:soap_client).operations
end
VCR.use_cassette 'i_check_gateway-wsdl' do
  AchClient::ICheckGateway.send(:soap_client).operations
end
