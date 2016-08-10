$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'codeclimate-test-reporter'

SimpleCov.start do
  add_filter '/test'
end

CodeClimate::TestReporter.start

require 'ach_client'
require 'minitest/autorun'
require 'minitest/mock'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require "minitest/reporters"
Minitest::Reporters.use!

# Configure test settings
AchClient::AchWorks.company_key = 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD'
AchClient::AchWorks.company = 'MYCOMPANY'
AchClient::AchWorks.loc_i_d = '9505'
AchClient::AchWorks.s_s_s = 'TST'
AchClient::AchWorks.wsdl = 'http://tstsvr.achworks.com/dnet/achws.asmx?wsdl'

require 'webmock/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcrs'
  config.hook_into :webmock
end

# Savon makes a request for the WSDL and caches it when the first request is
# made. We do this here in a VCR so that a future test is not the first request.
VCR.use_cassette 'wsdl' do
  AchClient::AchWorks.soap_client.operations
end
