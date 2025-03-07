# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ach_client/version'

Gem::Specification.new do |spec|
  spec.name = 'ach_client'
  spec.version = AchClient::VERSION
  spec.authors = [
    'Zach Cotter'
  ]
  spec.email = [
    'zach@zachcotter.com'
  ]
  spec.licenses = ['MIT']

  spec.summary = %q{ Adapter to interact with various ACH service providers }
  spec.homepage = 'https://github.com/ForwardFinancing/ach_client'

  spec.files = `git ls-files -z`.split(/\x0/)
                                .reject do |f|
                                  f.match(%r{^(test|spec|features)/})
                                end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = [
    'lib',
    'config'
  ]

  #spec.required_ruby_version = '>= 2.7.0'

  # NACHA library
  spec.add_dependency 'ach', '~> 0'

  # Handy ruby behavior from rails
  spec.add_dependency 'activesupport', '>= 6.0'

  # SFTP client (for Bank providers)
  spec.add_dependency 'net-sftp'

  # SOAP client (for AchWorks and ICheckGateway clients)
  spec.add_dependency 'savon', '~> 2'

  # Asynchronocity w/out extra infrastucture dependency (database/redis)
  spec.add_dependency 'sucker_punch', '~> 3'

  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'mocha', '~> 2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'bundler-audit'
end
