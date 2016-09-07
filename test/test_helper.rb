$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'codeclimate-test-reporter'

SimpleCov.start do
  add_filter '/test'
end

CodeClimate::TestReporter.start

# Freeze time so we don't have to worry about Time.now relativity
require 'timecop'
Timecop.freeze(DateTime.parse('2016-08-11T10:13:05-04:00'))

# Everything happens synchronously
require 'sucker_punch/testing/inline'

require 'ach_client'
require 'minitest/autorun'
require 'minitest/mock'
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
