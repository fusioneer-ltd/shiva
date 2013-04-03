require 'shiva/migrator'
require 'support/use_sqlite_database'
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
    context 'ponies' do
      # Never use checked-in files, always use copies!
      use_sqlite_database 'ponies'

      before :each do
        database = ShivaSpec::Database.new('Pony', 'ponies')
        Shiva::Migrator.migrate database
      end

      subject { Pony.columns }
      its(:size) { should eq 3 }
      it { subject.map(&:name).should include 'race' }
    end
    pending "oh my, no tests for migrate with version :("
  end

  pending "oh my, no tests for rollback :("
  pending "oh my, no tests for pending_migration :("

end
