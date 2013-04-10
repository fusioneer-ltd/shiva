require 'shiva/migrator'
require 'support/sqlite_database'
require 'active_record'
require 'models/pony'
module ShivaSpec
  class Database < Shiva::Database
    def migration_path
      "spec/migrations/#{name}/"
    end

    def schema_path
      "spec/schema/#{name}_schema.rb"
    end

    def seeds_path
      "spec/seeds/#{name}.rb"
    end
  end
end
describe Shiva::Migrator do

  describe :migrate do
    context 'without already existing database' do
      # Never use checked-in files, always use copies!
      remove_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::Database.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
      end

      subject { Pony.columns.map(&:name) }
      its(:size) { should eq 3 }
      it { should include 'race' }
    end

    context 'with already existing database' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::Database.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
      end

      subject { Pony.columns.map(&:name) }
      its(:size) { should eq 3 }
      it { should include 'race' }
    end
    pending "oh my, no tests for migrate with version :("
  end

  describe :rollback do
    context 'ponies' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::Database.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
        Shiva::Migrator.rollback database, 2
      end

      subject { Pony.columns.map(&:name) }
      its(:size) { should eq 2 }
      it { should_not include 'race' }
    end
  end

  pending "oh my, no tests for pending_migration :("

end
