# -*- encoding : utf-8 -*-
require 'shiva/migrator'
require 'shiva/dumper'
require 'active_record'
require 'models/pony'

unless defined?(Rails)
  module Rails
    def self.root; Dir.getwd; end
  end
end

describe Shiva::Dumper do

  context 'schema_format is :ruby' do
    before do
      Pony.should_receive(:schema_format).and_return(:ruby)
    end
    describe :dump do
      context 'without previous migrations' do
        # Never use checked-in files, always use copies!
        use_database 'ponies'
        before do
          catch_no_support do
            @database = ShivaSpec::DumperDatabase.new('Pony', 'ponies')
            Shiva::Dumper.dump(@database)
          end
        end
        subject { File.open(@database.schema_path,'r') }

        its(:read) { should match 'ActiveRecord::Schema.define' }
        its(:read) { should match 'create_table "ponies"' }
        its(:read) { should match 't.string "name"' }
        its(:read) { should_not match 't.string "race"' }
      end

      context 'with previous migrations' do
        # Never use checked-in files, always use copies!
        use_database 'ponies'
        before do
          catch_no_support do
            @database = ShivaSpec::DumperDatabase.new('Pony', 'ponies')
            Shiva::Migrator.migrate @database
            Shiva::Dumper.dump(@database)
          end
        end
        subject { File.open(@database.schema_path,'r') }

        its(:read) { should match 'ActiveRecord::Schema.define' }
        its(:read) { should match 'create_table "ponies"' }
        its(:read) { should match 't.string "name"' }
        its(:read) { should match 't.string "race"' }
      end
    end
  end

  context 'schema_format is :sql' do
    before do
      Rails.should_receive(:root).any_number_of_times.and_return(Dir.getwd)
      Pony.should_receive(:schema_format).and_return(:sql)
    end
    describe :dump do
      context 'without previous migrations' do
        # Never use checked-in files, always use copies!
        use_database 'ponies'
        before do
          catch_no_support do
            @database = ShivaSpec::DumperDatabase.new('Pony', 'ponies')
            Shiva::Dumper.dump(@database)
          end
        end
        subject { File.open(@database.structure_path,'r') }

        its(:read) { should match 'ponies' }
        its(:read) { should match 'name' }
        its(:read) { should_not match 'race' }
      end

      context 'with previous migrations' do
        # Never use checked-in files, always use copies!
        use_database 'ponies'
        before do
          catch_no_support do
            @database = ShivaSpec::DumperDatabase.new('Pony', 'ponies')
            Shiva::Migrator.migrate @database
            Shiva::Dumper.dump(@database)
          end
        end
        subject { File.open(@database.structure_path,'r') }

        its(:read) { should match 'ponies' }
        its(:read) { should match 'name' }
        its(:read) { should match 'race' }
      end
    end
  end
end
