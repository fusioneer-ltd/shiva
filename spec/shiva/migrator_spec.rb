# -*- encoding : utf-8 -*-
require 'shiva/migrator'
require 'support/sqlite_database'
require 'active_record'
require 'models/pony'
module ShivaSpec
  class MigratorDatabase < Shiva::Database
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
        database = ShivaSpec::MigratorDatabase.new('Pony', 'ponies')
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
        database = ShivaSpec::MigratorDatabase.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
      end

      subject { Pony.columns.map(&:name) }
      its(:size) { should eq 3 }
      it { should include 'race' }
    end

    context 'with a specific version' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::MigratorDatabase.new('Pony', 'ponies')
        begin
          old_env_version = ENV['VERSION']
          ENV['VERSION'] = '2'
          Shiva::Migrator.migrate database
        ensure
          ENV['VERSION'] = old_env_version
        end
      end

      subject { Pony.columns.map(&:name) }
      its(:size) { should eq 3 }
      it { should include 'race' }
    end
  end

  describe :rollback do
    context 'columns' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::MigratorDatabase.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
        Shiva::Migrator.rollback database, 1
        Pony.reset_column_information
      end

      subject { Pony.columns.map(&:name) }
      its(:size) {should eq 2 }
      # weird JDBC bug where reset_column_information doesn't reset
      # column information right after a rollback in SQLite
      it {Pony.reset_column_information;  should_not include 'race' }
    end

    context 'model' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::MigratorDatabase.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
        Shiva::Migrator.rollback database, 2
        Pony.reset_column_information
      end

      subject { Pony }
      its(:table_exists?) { should be_false }
    end
  end

  describe :pending_migrations do
    # Never use checked-in files, always use copies!
    use_sqlite_database 'ponies'
    before { @database = ShivaSpec::MigratorDatabase.new('Pony', 'ponies') }
    subject { Shiva::Migrator.pending_migrations(@database) }

    its(:size) { should eq 1 }
    # version number
    it { subject.first.version.should eq 2}
  end

end
