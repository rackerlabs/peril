require 'minitest/autorun'
require 'database_cleaner'

require 'peril'

include Peril

DatabaseCleaner.strategy = :transaction
