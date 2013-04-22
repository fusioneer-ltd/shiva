# -*- encoding : utf-8 -*-
require 'rake'

shiva_namespace = namespace :shiva do
  desc 'Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog).'
  task :migrate, [:database_name] => :environment do |_, args|
    require 'shiva/migrator'

    apply_to_databases args do |database_configuration|
      Shiva::Migrator.migrate(database_configuration)
      shiva_namespace[:dump].invoke(args)
    end
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback, [:database_name] => :environment do |_, args|
    require 'shiva/migrator'

    apply_to_databases args do |database_configuration|
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      Shiva::Migrator.rollback(database_configuration, step)

      shiva_namespace[:dump].invoke(args)
    end
  end

  desc 'Create a db/schema/db_name.rb file that can be portably used against any DB supported by AR'
  task :dump, [:database_name] => :environment do |_, args|
    require 'shiva/dumper'

    apply_to_databases args do |database_configuration|
      Shiva::Dumper.dump(database_configuration)
    end
  end

  task :abort_if_pending_migrations, [:database_name] => :environment do |_, args|
    require 'shiva/migrator'

    apply_to_databases args do |database_configuration|
      pending_migrations = Shiva::Migrator.pending_migrations(database_configuration)

      if pending_migrations.any?
        puts "You have #{pending_migrations.size} pending migrations for database #{database_configuration.name}:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort %{Run `rake shiva:migrate[#{database_configuration.name}]` to update your database then try again.}
      end
    end
  end

  desc 'Load the seed data from db/seeds/db_name.rb'
  task :seeds, [:database_name] => :environment do |_, args|
    shiva_namespace['abort_if_pending_migrations'].invoke(*args)

    apply_to_databases args do |database_configuration|
      if File.exists?(database_configuration.seeds_path)
        load(database_configuration.seeds_path)
      end
    end
  end

  namespace :schema do
    desc 'Load a schema.rb file into the database'
    task :load, [:database_name] => :environment do |_, args|
      apply_to_databases args do |database_configuration|
        path = defined?(Rails) ? Rails.root : Dir.getwd
        file = ENV['SCHEMA'] || File.join(path, database_configuration.schema_path)
        if File.exists?(file)
          ActiveRecord::Base.establish_connection(database_configuration.base_model.connection.config)
          load(file)
        else
          abort %{#{file} doesn't exist yet. Run `rake shiva:migrate` to create it, then try again. If you do not intend to use a database, you should instead alter #{path}/config/application.rb to limit the frameworks that will be loaded.}
        end
      end
    end
  end

  namespace :structure do
    # desc "Recreate the databases from the structure.sql file"
    task :load, [:database_name] => :environment do |_, args|
      apply_to_databases args do |database_configuration|
        path = defined?(Rails) ? Rails.root : Dir.getwd
        filename = ENV['DB_STRUCTURE'] || File.join(path, database_configuration.structure_path)
        config = database_configuration.base_model.connection.config.with_indifferent_access
        if defined?(ActiveRecord::Tasks::DatabaseTasks)
          # ActiveRecord 4
          ActiveRecord::Tasks::DatabaseTasks.structure_load(config, filename)
        else
          require 'shiva/legacy_tasks'
          Shiva::LegacyTasks.structure_load(database_configuration, filename)
        end
      end
    end
  end

  def apply_to_databases arguments
    database_name = arguments[:database_name]

    Shiva.configuration._databases.each do |database_configuration|
      yield database_configuration if database_name.nil? || database_configuration.name == database_name
    end
  end
end
