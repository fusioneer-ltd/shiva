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

  desc 'Create a db/schema/db_name.rb file that can be portably used against any DB supported by AR'
  task :dump, [:database_name] => :environment do |_, args|
    require 'shiva/dumper'

    apply_to_databases args do |database_configuration|
      Shiva::Dumper.dump(database_configuration)
    end
  end

  def apply_to_databases arguments
    database_name = arguments[:database_name]

    Shiva.configuration._databases.each do |database_configuration|
      yield database_configuration if database_name.nil? || database_configuration.name == database_name
    end
  end
end
