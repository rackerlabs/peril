require 'log4r'

ENV['PERIL_ENV'] ||= 'test'
Log4r::Logger.root.level = Log4r::FATAL unless ENV['PERIL_TEST_LOGGING']

require 'minitest/autorun'
require 'database_cleaner'

require 'peril'

include Peril

# Configure the database.
DatabaseCleaner.strategy = :truncation
Peril::Config.get.dbconnect!

module Cleaned
  def before_setup
    super
    DatabaseCleaner.clean
  end
end
