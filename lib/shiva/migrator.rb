# -*- encoding : utf-8 -*-
require 'shiva/database'

class Shiva::Migrator
  def self.migrate database
    using_connection database.base_model.connection do
      ::ActiveRecord::Migration.verbose = verbose?
      ::ActiveRecord::Migrator.migrate("db/migrate/#{database.name}/", version) do |migration|
        ENV['SCOPE'].blank? || (ENV['SCOPE'] == migration.scope)
      end
    end
  end

  private
  def self.using_connection connection
    original = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection connection.config
    yield
  ensure
    ActiveRecord::Base.establish_connection original
  end

  def self.verbose?
    ENV['VERBOSE'] ? ENV['VERBOSE'] == 'true' : true
  end

  def self.version
    ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end
end
