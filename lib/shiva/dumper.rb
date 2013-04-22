# -*- encoding : utf-8 -*-
require 'shiva/database'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_record/schema_dumper'
require 'shiva/legacy_tasks'

module Shiva
  class Dumper
    def self.dump database
      path = defined?(Rails) ? Rails.root : Dir.getwd
      case database.base_model.schema_format
      when :ruby
      then
        File.open(File.join(path, database.schema_path), 'w') do |file|
          ActiveRecord::SchemaDumper.dump database.base_model.connection, file
        end
      when :sql
      then
        filename = ENV['DB_STRUCTURE'] || File.join(path, database.structure_path)
        config = database.base_model.connection.config.with_indifferent_access
        if defined?(ActiveRecord::Tasks::DatabaseTasks)
          # ActiveRecord 4
          ActiveRecord::Tasks::DatabaseTasks.structure_dump(config, filename)
        else
          # ActiveRecord 3
          Shiva::LegacyTasks.structure_dump(database, filename)
        end
        if database.base_model.connection.supports_migrations?
          File.open(filename, 'a') do |f|
            f.puts database.base_model.connection.dump_schema_information
          end
        end
      else
        raise "unknown schema format #{database.base_model.schema_format}"
      end
    end
  end
end
