require 'minitest/autorun'
require 'database_cleaner'
require 'fog'

require 'peril'

include Peril

# Configure the database.
DatabaseCleaner.strategy = :transaction
Peril::Config.get.dbconnect!

# Tell Fog to use mocks.
Fog.mock!
