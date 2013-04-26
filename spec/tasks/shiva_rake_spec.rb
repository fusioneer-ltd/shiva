# -*- encoding : utf-8 -*-
require 'rake'
require 'active_record'
require 'models/pony'
require 'shiva/dumper'
module ShivaSpec
  class ShivaRakeDatabase < Shiva::Database
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

unless defined?(Rails)
  module Rails
    def self.root; Dir.getwd; end
  end
end
describe 'shiva namespace rake task' do
  before :all do
    Rake.application.rake_require 'tasks/shiva'
    Rake::Task.define_task(:environment)
    Shiva.configure do; end
  end

  context 'with empty configuration' do
    describe 'shiva:migrate' do
      let :run_rake_task do
        Rake::Task['shiva:migrate'].reenable
        Rake.application.invoke_task 'shiva:migrate'
      end

      it 'runs!' do
        Shiva.configuration.should_receive(:_databases).and_return([])
        run_rake_task
      end
    end

    describe 'shiva:rollback' do
      let :run_rake_task do
        Rake::Task['shiva:rollback'].reenable
        Rake.application.invoke_task 'shiva:rollback'
      end

      it 'runs!' do
        Shiva.configuration.should_receive(:_databases).and_return([])
        run_rake_task
      end
    end

    describe 'shiva:dump' do
      let :run_rake_task do
        Rake::Task['shiva:dump'].reenable
        Rake.application.invoke_task 'shiva:dump'
      end

      it 'runs!' do
        catch_no_support do
          Shiva.configuration.should_receive(:_databases).and_return([])
          run_rake_task
        end
      end
    end

    describe 'shiva:abort_if_pending_migrations' do
      let :run_rake_task do
        Rake::Task['shiva:abort_if_pending_migrations'].reenable
        Rake.application.invoke_task 'shiva:abort_if_pending_migrations'
      end

      it 'runs!' do
        Shiva.configuration.should_receive(:_databases).and_return([])
        run_rake_task
      end
    end

    # depends on #abort_if_pending_migrations
    describe 'shiva:seeds' do
      let :run_rake_task do
        Rake::Task['shiva:seeds'].reenable
        Rake::Task['shiva:abort_if_pending_migrations'].reenable
        Rake.application.invoke_task 'shiva:seeds'
      end

      it 'runs!' do
        Shiva.configuration.should_receive(:_databases).exactly(2).times.and_return([])
        run_rake_task
      end
    end
  end

  context 'with configuration' do
    use_database 'ponies'
    before :each do
      @database = ShivaSpec::ShivaRakeDatabase.new('Pony', 'ponies')
      Shiva.configure do
        @databases = [ShivaSpec::ShivaRakeDatabase.new('Pony', 'ponies')]
      end
    end

    describe 'shiva:migrate' do
      let :run_rake_task do
        Rake::Task['shiva:migrate'].reenable
        silence_active_record do
          Rake.application.invoke_task 'shiva:migrate'
        end
      end

      it 'runs!' do
        run_rake_task
      end
    end

    describe 'shiva:rollback' do
      let :run_rake_task do
        Rake::Task['shiva:rollback'].reenable
        Rake.application.invoke_task 'shiva:rollback'
      end

      it 'runs!' do
        silence_active_record { run_rake_task }
      end
    end

    describe 'shiva:dump' do
      let :run_rake_task do
        Rake::Task['shiva:dump'].reenable
        Rake.application.invoke_task 'shiva:dump'
      end

      it 'runs!' do
        run_rake_task
      end
    end

    describe 'shiva:abort_if_pending_migrations' do
      let :run_rake_task do
        Rake::Task['shiva:abort_if_pending_migrations'].reenable
        Rake.application.invoke_task 'shiva:abort_if_pending_migrations'
      end

      it 'aborts on pending migrations!' do
        lambda { run_rake_task }.should raise_error SystemExit
      end

      it 'runs for no pending migrations!' do
        silence_active_record { Shiva::Migrator.migrate(@database) }
        lambda { run_rake_task }.should_not raise_error SystemExit
      end
    end

    # depends on #abort_if_pending_migrations
    describe 'shiva:seeds' do
      let :run_rake_task do
        Rake::Task['shiva:seeds'].reenable
        Rake::Task['shiva:abort_if_pending_migrations'].reenable
        Rake.application.invoke_task 'shiva:seeds'
      end

      it 'aborts on pending migrations!' do
        lambda { run_rake_task }.should raise_error SystemExit
      end

      it 'runs for no pending migrations!' do
        silence_active_record { Shiva::Migrator.migrate(@database) }
        lambda { run_rake_task }.should_not raise_error SystemExit
      end

    end

    context 'shiva:schema' do
      describe 'load' do
        context 'with an existing file' do
          before do
            Pony.connection.disconnect!
          end
          remove_database('ponies')

          let :run_rake_task do
            silence_active_record do
              Rake::Task['shiva:schema:load'].reenable
              Rake.application.invoke_task 'shiva:schema:load'
            end
          end

          it 'runs!' do
            Pony.establish_connection(AR_ADAPTER)
            Pony.reset_column_information
            Pony.should_not be_table_exists
            run_rake_task
            Pony.reset_column_information
            Pony.should be_table_exists
            Pony.columns.map(&:name).should include 'id', 'name'
          end
        end

        context 'without schema file' do
          before do
            ShivaSpec::ShivaRakeDatabase.any_instance.stub(:schema_path).and_return('non_existing_file')
          end

          let :run_rake_task do
            silence_active_record do
              Rake::Task['shiva:schema:load'].reenable
              Rake.application.invoke_task 'shiva:schema:load'
            end
          end

          it 'aborts on no file' do
            lambda { run_rake_task }.should raise_error SystemExit
          end
        end
      end
    end

    context 'shiva:structure' do
      describe 'load' do
        context 'with an existing file' do
          use_database('ponies')

          before do
            catch_no_support do
              Rails.should_receive(:root).any_number_of_times.and_return(Dir.getwd)
              @database = ShivaSpec::ShivaRakeDatabase.new('Pony', 'ponies')
              Shiva::Dumper.dump(@database)
            end
          end

          let :run_rake_task do
            silence_active_record do
              Rake::Task['shiva:structure:load'].reenable
              Rake.application.invoke_task 'shiva:structure:load'
            end
          end

          it 'runs!' do
            Pony.reset_column_information
            catch_no_support do
              run_rake_task
            end
            Pony.reset_column_information
            Pony.should be_table_exists
            Pony.columns.map(&:name).should include 'id', 'name'
          end
        end
      end
    end
  end

end
