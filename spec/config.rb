# -*- encoding : utf-8 -*-
SPEC_ROOT       = File.expand_path(File.dirname(__FILE__))
ASSETS_ROOT     = SPEC_ROOT + '/assets'
FIXTURES_ROOT   = SPEC_ROOT + '/fixtures'
MIGRATIONS_ROOT = SPEC_ROOT + '/migrations'
SCHEMA_ROOT     = SPEC_ROOT + '/schema'
VERBOSE ||= false

def require_default(database, adapter)
  if database[adapter] && database[adapter]['adapter']
    require database[adapter]['adapter']
  else
    require adapter
  end
end

if File.exists?(File.dirname(__FILE__) + '/database.yml')
  require 'yaml'
  database = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  adapter = ENV['DB'] || 'mysql'
  if defined?(JRUBY_VERSION)
    case adapter
    when 'mssql'
      #require 'activerecord-jdbc-adapter'
      require 'jdbc/jtds'
      Jdbc::JTDS.load_driver if Jdbc::JTDS.respond_to?(:load_driver)
    when 'sqlite'
      require 'jdbc/sqlite3'
      Jdbc::SQLite3.load_driver if Jdbc::SQLite3.respond_to?(:load_driver)
      adapter = 'jdbcsqlite3'
    else
      require_default(database, adapter)
    end
  else
    case adapter
    when /mysql/
      require 'mysql2'
    when /postgres/
      require 'pg'
    when /sqlite/
      require (adapter = 'sqlite3')
    else
      require_default(database, adapter)
    end
  end
  require 'active_record'
  require 'active_support'
  ActiveRecord::Base.configurations.update database
  case adapter
  when /sqlite/
    AR_ADAPTER = {adapter: adapter, database: File.join(SPEC_ROOT, 'tmp', 'ponies.sqlite')}
  else
    AR_ADAPTER = adapter
  end
else
  if defined?(JRUBY_VERSION)
    require 'jdbc/sqlite3'
    Jdbc::SQLite3.load_driver if Jdbc::SQLite3.respond_to?(:load_driver)

    sqlite_adapter = 'jdbcsqlite3'
  else
    require 'sqlite3'

    sqlite_adapter = 'sqlite3'
  end
  AR_ADAPTER = {adapter: sqlite_adapter, database: File.join(SPEC_ROOT, 'tmp', 'ponies.sqlite')}
end
