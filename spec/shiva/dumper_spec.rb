require 'shiva/migrator'
require 'shiva/dumper'
require 'active_record'
require 'models/pony'
module ShivaSpec
  class DumperDatabase < Shiva::Database
    def migration_path
      "spec/migrations/#{name}/"
    end

    def schema_path
      "spec/tmp/#{name}_schema.rb"
    end

    def seeds_path
      "spec/seeds/#{name}.rb"
    end
  end
end
describe Shiva::Dumper do

  describe :dump do
    context 'without previous migrations' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'
      before do
        @database = ShivaSpec::DumperDatabase.new('Pony', 'ponies')
        Shiva::Dumper.dump(@database)
      end
      subject { File.open(@database.schema_path,'r') }

      its(:read) { should match 'ActiveRecord::Schema.define' }
      its(:read) { should match 'create_table "ponies", :force => true' }
      its(:read) { should match 't.string "name"' }
      its(:read) { should_not match 't.string "race"' }
    end

    context 'with previous migrations' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'
      before do
        @database = ShivaSpec::DumperDatabase.new('Pony', 'ponies')
        Shiva::Migrator.migrate @database
        Shiva::Dumper.dump(@database)
      end
      subject { File.open(@database.schema_path,'r') }

      its(:read) { should match 'ActiveRecord::Schema.define' }
      its(:read) { should match 'create_table "ponies", :force => true' }
      its(:read) { should match 't.string "name"' }
      its(:read) { should match 't.string "race"' }
    end
  end

end
