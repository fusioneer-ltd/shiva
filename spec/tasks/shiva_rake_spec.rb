# -*- encoding : utf-8 -*-
require 'rake'
require 'active_record'
require 'models/pony'
module ShivaSpec
  class ShivaRakeDatabase < Shiva::Database
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
        Shiva.configuration.should_receive(:_databases).and_return([])
        run_rake_task
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
    use_sqlite_database 'ponies'
    before :each do
      @database = ShivaSpec::ShivaRakeDatabase.new('Pony', 'ponies')
      Shiva.configure do
        @databases = [ShivaSpec::ShivaRakeDatabase.new('Pony', 'ponies')]
      end
    end

    describe 'shiva:migrate' do
      let :run_rake_task do
        Rake::Task['shiva:migrate'].reenable
        Rake.application.invoke_task 'shiva:migrate'
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
        run_rake_task
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
        Shiva::Migrator.migrate @database
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
        Shiva::Migrator.migrate @database
        lambda { run_rake_task }.should_not raise_error SystemExit
      end

    end
  end

end
