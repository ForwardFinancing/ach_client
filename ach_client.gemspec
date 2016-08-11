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

  spec.summary = %q{ Adapter to interact with various ACH service providers }
  spec.homepage = 'https://github.com/ForwardFinancing/ach_client'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against gem pushes.'
  end

  spec.files = `git ls-files -z`.split(/\x0/)
                                .reject do |f|
                                  f.match(%r{^(test|spec|features)/})
                                end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = [
    'lib'
  ]

  # Handy ruby behavior from rails
  spec.add_dependency 'activesupport'

  # SOAP client (for AchWorks client)
  spec.add_dependency 'savon', '~> 2'

  # Asynchronocity w/out extra infrastucture dependency (database/redis)
  spec.add_dependency 'sucker_punch', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
end
