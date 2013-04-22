# -*- encoding : utf-8 -*-
module SqliteDatabase
  module Extends
    def use_sqlite_database(database_name)
      before :each do
        FileUtils.cp fixture_sqlite_database_file_path(database_name), tmp_sqlite_database_file_path(database_name)
      end
    end

    def remove_sqlite_database(database_name)
      before :each do
        FileUtils.rm(tmp_sqlite_database_file_path(database_name), force: true)
      end
    end
  end

  module Includes

    def silence_active_record(&block)
      arm = ActiveRecord::Migration.verbose
      ActiveRecord::Migration.verbose = false
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
  config.extend SqliteDatabase::Extends
  config.include SqliteDatabase::Includes
end
