require 'minitest/autorun'
require 'database_cleaner'
require 'fog'

require 'peril'

ENV['PERIL_ENV'] = 'test'

include Peril

# Configure the database.
DatabaseCleaner.strategy = :transaction
Peril::Config.dbconnect!('test')

# Tell Fog to use mocks.
Fog.mock!
