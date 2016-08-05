require 'pry'
# Require all of the files in lib
Dir['./lib/**/*.rb'].sort.each { |f| require(f) }

# Require some ruby helpers from rails land
require 'active_support/all'

# Adapter for interacting with various Ach service providers
module AchClient

end
