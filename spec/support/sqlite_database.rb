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
          FileUtils.rm(tmp_sqlite_database_file_path(database_name), force: true)
        end
      end
    else
      def use_database(database_name)
        before :each do
          silence_active_record do
            ActiveRecord::Base.establish_connection(ENV['DB'])
            drop_statement = "DROP TABLE #{'IF EXISTS ' unless ENV['DB'] =~ /mssql/}#{ActiveRecord::Base.connection.quote_table_name(database_name)}"
            ActiveRecord::Base.connection.execute(drop_statement)
            load(File.join(SCHEMA_ROOT, 'ponies_schema.rb'))
          end
        end
      end

      def remove_database(database_name)
        before :each do
          ActiveRecord::Base.establish_connection($database[ENV['DB']])
          ActiveRecord::Base.connection.execute("DROP TABLE #{'IF EXISTS ' unless ENV['DB'] =~ /mssql/}#{database_name}")
        end
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
  config.extend DatabaseHelper::Extends
  config.include DatabaseHelper::Includes
end
