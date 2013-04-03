# -*- encoding : utf-8 -*-
require 'shiva/database'

class Shiva::Migrator
  def self.migrate database
    using_connection database.base_model.connection do
      ::ActiveRecord::Migration.verbose = verbose?
      ::ActiveRecord::Migrator.migrate(database.migration_path, version) do |migration|
        ENV['SCOPE'].blank? || (ENV['SCOPE'] == migration.scope)
      end
    end
  end

  def self.rollback database, step
    using_connection database.base_model.connection do
      ::ActiveRecord::Migrator.rollback(database.migration_path, step)
    end
  end

  def self.pending_migrations database
    using_connection database.base_model.connection do
      if ::ActiveRecord::Migrator.respond_to?(:open)
        ::ActiveRecord::Migrator.open(database.migration_path).pending_migrations
      else
        ::ActiveRecord::Migrator.new(:up, database.migration_path).pending_migrations
      end
    end
  end

  private
  def self.using_connection connection
    original = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection connection.config
    yield
  ensure
    # only reconnect if there was a connection
    ActiveRecord::Base.establish_connection(original) if original
  end

  def self.verbose?
    ENV['VERBOSE'] ? ENV['VERBOSE'] == 'true' : (defined?(VERBOSE) ? VERBOSE : true)
  end

  def self.version
    ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end
end
