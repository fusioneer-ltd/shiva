# -*- encoding : utf-8 -*-
require 'shiva/database'
module ShivaSpec
  class DumperDatabase < Shiva::Database
    def migration_path
      "spec/migrations/#{name}/"
    end

    def schema_path
      "spec/tmp/#{name}_schema.rb"
    end

    def structure_path
      "spec/tmp/#{name}_structure.sql"
    end

    def seeds_path
      "spec/seeds/#{name}.rb"
    end
  end
end
module DatabaseHelper
  module Extends
    case ENV['DB']
    when /sqlite/
      def use_database(database_name)
        before :each do
          FileUtils.cp fixture_sqlite_database_file_path(database_name), tmp_sqlite_database_file_path(database_name)
        end
      end

      def remove_database(database_name)
        before :each do
          FileUtils.rm(tmp_sqlite_database_file_path(database_name), force: true, verbose: ENV['verbose'].present?)
        end
      end

      def drop_database(database_name); remove_database(database_name); end
    else
      def use_database(database_name)
        before :each do
          silence_active_record do
            if ENV['TRAVIS'].present? && /postgres/.match(ENV['DB'])
              `psql -c 'DROP DATABASE IF EXISTS shiva_test;' -U postgres`
              `psql -c 'create database shiva_test;' -U postgres`
            end
            require 'shiva/database'
            require 'shiva/migrator'
            database = ShivaSpec::DumperDatabase.new(database_name.classify.singularize, database_name.tableize)
            Shiva::Migrator.migrate(database)
            Shiva::Migrator.rollback(database, 1)
          end
        end
      end

      def remove_database(database_name)
        before :each do
          silence_active_record do
            if ENV['TRAVIS'].present? && /postgres/.match(ENV['DB'])
              `psql -c 'DROP DATABASE IF EXISTS shiva_test;' -U postgres`
              `psql -c 'create database shiva_test;' -U postgres`
            else
              require 'shiva/database'
              require 'shiva/migrator'
              database = ShivaSpec::DumperDatabase.new(database_name.classify.singularize, database_name.tableize)
              Shiva::Migrator.migrate(database)
              Shiva::Migrator.rollback(database, 1000)
            end
          end
        end
      end

      def drop_database(database_name)
        before :each do
          database = ShivaSpec::DumperDatabase.new(database_name.classify.singularize, database_name.tableize)
          case database.config['adapter']
          when /mysql/
            ActiveRecord::Base.establish_connection(database.config)
            ActiveRecord::Base.connection.recreate_database database.config['database']
          when /postgres/
            database.base_model.connection.disconnect!
            if ENV['TRAVIS'].present?
              `psql -c 'DROP DATABASE IF EXISTS shiva_test;' -U postgres`
              `psql -c 'create database shiva_test;' -U postgres`
            else
              ActiveRecord::Base.establish_connection(database.config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
              ActiveRecord::Base.connection.recreate_database database.config['database']
              ActiveRecord::Base.connection.disconnect!
            end
            database.base_model.establish_connection(database.config)
          end
        end
     end
    end
  end

  module Includes

    def silence_active_record(&block)
      arm = ActiveRecord::Migration.verbose
      ActiveRecord::Migration.verbose = false unless ENV['verbose']
      yield
    ensure
      ActiveRecord::Migration.verbose = arm
    end

    protected

    def tmp_sqlite_database_file_path(database_name)
      database_name += '.sqlite' if database_name[-7,7] != '.sqlite'
      File.join(SPEC_ROOT, 'tmp', database_name)
    end

    def fixture_sqlite_database_file_path(database_name)
      database_name += '.sqlite' if database_name[-7,7] != '.sqlite'
      File.join(FIXTURES_ROOT, 'databases', database_name)
    end
  end
end

RSpec.configure do |config|
  config.extend DatabaseHelper::Extends
  config.include DatabaseHelper::Includes
end
