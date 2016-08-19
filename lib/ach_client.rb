require 'active_support/all'
require 'savon'
require 'sucker_punch'

# Require all of the files in lib
Dir['../ach_client/lib/**/*.rb'].sort.each do |f|
  require(f.split('../ach_client/lib/').last.split('.rb').first)
end

# Adapter for interacting with various Ach service providers
module AchClient

end
