# -*- encoding : utf-8 -*-
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
    else
      def use_database(database_name)
        before :each do
          silence_active_record do
            require 'shiva/database'
            require 'shiva/migrator'
            database = Shiva::Database.new(database_name.classify.singularize, database_name.tableize)
            Shiva::Migrator.migrate(database)
            Shiva::Migrator.rollback(database, 1)
          end
        end
      end

      def remove_database(database_name)
        before :each do
          silence_active_record do
            require 'shiva/database'
            require 'shiva/migrator'
            database = Shiva::Database.new(database_name.classify.singularize, database_name.tableize)
            Shiva::Migrator.rollback(database, 4)
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
