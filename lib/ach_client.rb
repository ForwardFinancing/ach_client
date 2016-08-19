require 'active_support/all'
require 'savon'
require 'sucker_punch'

# Require all of the files in lib
Dir['./lib/**/*.rb'].sort.each { |f| require(f) }

# Adapter for interacting with various Ach service providers
module AchClient

end
