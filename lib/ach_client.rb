require 'active_support/all'
require 'savon'
require 'sucker_punch'

# Require all of the files in lib
Dir[Gem::Specification.find_by_name("ach_client").gem_dir + '/lib/**/*.rb'].sort.each do |f|
  require(f.split('/lib/').last.split('.rb').first)
end

# Adapter for interacting with various Ach service providers
module AchClient

end
