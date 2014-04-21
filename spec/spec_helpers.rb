require 'log4r'

ENV['PERIL_ENV'] ||= 'test'
Log4r::Logger.root.level = Log4r::FATAL unless ENV['PERIL_TEST_LOGGING']

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
