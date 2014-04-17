require 'minitest/autorun'
require 'database_cleaner'

require 'peril'

include Peril

# Configure the database.
DatabaseCleaner.strategy = :transaction
Peril::Config.dbconnect!('test')
