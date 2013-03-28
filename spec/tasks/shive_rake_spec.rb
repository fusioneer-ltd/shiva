require 'rake'

describe 'shiva namespace rake task' do
  before :all do
    Rake.application.rake_require 'tasks/shiva'
    Rake::Task.define_task(:environment)
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
end
