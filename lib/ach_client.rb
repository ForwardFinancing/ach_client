require 'ach'
require 'active_support/all'
require 'savon'
require 'sucker_punch'

# Require all of the files in lib
Dir[Gem::Specification.find_by_name("ach_client").gem_dir + '/lib/**/*.rb'].sort.each do |f|
  require(f.split('/lib/').last.split('.rb').first)
end

# Adapter for interacting with various Ach service providers
module AchClient

  # Enables consumer to interact with new Sftp/NACHA providers without adding
  # them to the codebase!!
  # Lets say the consumer wants to integrate with Citibank.
  # They would invoke AchClient::Citibank, which would be undefined.
  # This const_missing would be called, and the Citibank module would be
  # dynamically defined, with all the necessary Sftp/NACHA concerns included and
  # ready for use.
  # This is only helpful because many financial institutions use the same setup
  # with NACHA and an SFTP server.
  def self.const_missing(name)
    const_set(
      name,
      Class.new do
        include AchClient::SftpProvider
        include AchClient::NachaProvider

        # Defines the classes within the provider namespace to use for
        # sending transactions
        const_set(:AchTransaction, Class.new(Sftp::AchTransaction))
        const_set(:AchBatch, Class.new(Sftp::AchBatch))
        const_set(:AchStatusChecker, Class.new(Sftp::AchStatusChecker))
      end
    )
  end
end
