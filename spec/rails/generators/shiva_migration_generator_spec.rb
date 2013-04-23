require 'rails/generators/shiva_migration_generator'
require 'models/pony'
require 'shiva/database'
require 'shiva/configurator'

module ShivaSpec
  class ShivaMigrationDatabase < Shiva::Database
    def migration_path
      "spec/tmp/migrations/#{name}/"
    end
  end
end
describe Shiva::MigrationGenerator do

  use_sqlite_database 'ponies'
  before do
    Shiva.configure do
      @databases << ShivaSpec::ShivaMigrationDatabase.new('Pony', 'ponies')
    end
  end

  # just testing that it runs, it's descending from a rails generator, which is tested there
  it 'runs' do
    FileUtils.rm_rf(Dir[File.join(File.dirname(__FILE__),'..', '..', 'tmp', 'migrations')])
    described_class.start ["ponies", "add_coat_color_to_ponies"]
    Dir[File.join(File.dirname(__FILE__),'..', '..', 'tmp', 'migrations', 'ponies')].should_not be_empty
  end

  it 'fails on no database found error' do
    lambda {
      described_class.start ["non_existing_database", "add_coat_color_to_ponies"]
    }.should raise_error ArgumentError
  end
end
