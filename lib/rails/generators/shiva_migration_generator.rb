require 'rails/generators'
require 'rails/generators/migration'
begin
  require 'rails/generators/active_record/migration'
rescue LoadError
  # do nothing, it's a Rails 3 file, if we're in Rails 4, we're fine
end
require 'rails/generators/active_record'
require 'rails/generators/named_base'
require 'rails/generators/rails/migration/migration_generator'
require 'rails/generators/active_record/migration/migration_generator'

module Shiva
  class MigrationGenerator < ActiveRecord::Generators::MigrationGenerator # :nodoc:
    def initialize(args, *options) #:nodoc:
      @inside_template = nil
      # Unfreeze name in case it's given as a frozen string
      args[0] = args[0].dup if args[0].is_a?(String) && args[0].frozen?
      database_name = args.shift

      @database = Shiva.configuration._databases.select do |database|
        database.name == database_name
      end.first || raise(ArgumentError.new('You have to specify database name for a migration!'))

      super
    end

    def create_migration_file
      set_local_assigns!
      # Forward-compatibility with Rails 4
      validate_file_name! if respond_to?(:validate_file_name!)
      migration_template (@migration_template || 'migration.rb'), File.join(@database.migration_path, "#{file_name}.rb")
    end

    def self.source_root
      # trick Rails generator to use ActiveRecord templates
      @_source_root = ActiveRecord::Generators::MigrationGenerator.source_root
    end
  end
end
