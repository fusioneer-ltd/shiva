# -*- encoding : utf-8 -*-
SPEC_ROOT       = File.expand_path(File.dirname(__FILE__))
ASSETS_ROOT     = SPEC_ROOT + '/assets'
FIXTURES_ROOT   = SPEC_ROOT + '/fixtures'
MIGRATIONS_ROOT = SPEC_ROOT + '/migrations'
SCHEMA_ROOT     = SPEC_ROOT + '/schema'
VERBOSE ||= false

if defined?(JRUBY_VERSION)
  require 'jdbc/sqlite3'
  Jdbc::SQLite3.load_driver if Jdbc::SQLite3.respond_to?(:load_driver)

  SQLITE_ADAPTER = 'jdbcsqlite3'
else
  require 'sqlite3'

  SQLITE_ADAPTER = 'sqlite3'
end
