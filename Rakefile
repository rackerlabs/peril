require 'rake/testtask'
require 'active_record'
require 'yaml'
require 'log4r'

require_relative 'lib/peril/config'

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

task :default => :test

MIGRATIONS_DIR = File.join __dir__, 'db', 'migrations'

namespace :db do

  # Non-Rails ActiveRecord integration courtesy of:
  # http://exposinggotchas.blogspot.com/2011/02/activerecord-migrations-without-rails.html

  task :connect do
    Peril::Config.dbconnect!
  end

  desc 'Migrate the database. Options: VERSION=x, VERBOSE=false'
  task :migrate => :connect do
    ActiveRecord::Migration.verbose = !! ENV['VERBOSE']
    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    ActiveRecord::Migrator.migrate MIGRATIONS_DIR, version
  end

  desc 'Rolls the schema back to the previous version. Options: STEPS=n'
  task :rollback => :connect do
    step = ENV['STEPS'] ? ENV['STEPS'].to_i : 1
    ActiveRecord::Migrator.rollback MIGRATIONS_DIR, step
  end

  desc 'Retrieves the current schema version number'
  task :version => :connect do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  desc 'Create a new timestamp-prefixed migration. Options: NAME=string'
  task :createmigration do
    # Poor man's generator.
    uname = ENV['NAME'] || 'migration'

    cname = uname.gsub(/_(.)/) { |m| m[1].upcase }
    cname[0] = cname[0].upcase

    fname = [Time.now.to_i, uname].join '_'
    path = File.join MIGRATIONS_DIR, "#{fname}.rb"
    File.write(path, <<EOF)
class #{cname} < ActiveRecord::Migration
  def up
  end

  def down
  end
end
EOF
  end

end
