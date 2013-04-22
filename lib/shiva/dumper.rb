# -*- encoding : utf-8 -*-
require 'shiva/database'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_record/schema_dumper'

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
          case config['adapter']
          when /mysql/, 'oci', 'oracle'
            database.base_model.establish_connection(config)
            File.open(filename, 'w:utf-8') { |f| f << database.base_model.connection.structure_dump }
          when /postgresql/
            set_psql_env(config)
            search_path = config['schema_search_path']
            unless search_path.blank?
              search_path = search_path.split(",").map{|search_path_part| "--schema=#{Shellwords.escape(search_path_part.strip)}" }.join(" ")
            end
            `pg_dump -i -s -x -O -f #{Shellwords.escape(filename)} #{search_path} #{Shellwords.escape(config['database'])}`
            raise 'Error dumping database' if $?.exitstatus == 1
          when /sqlite/
            dbfile = config['database']
            `sqlite3 #{dbfile} .schema > #{filename}`
          when 'sqlserver'
            `smoscript -s #{config['host']} -d #{config['database']} -u #{config['username']} -p #{config['password']} -f #{filename} -A -U`
          when "firebird"
            set_firebird_env(config)
            db_string = firebird_db_string(config)
            FileUtils.sh "isql -a #{db_string} > #{filename}"
          else
            raise "Task not supported by '#{config['adapter']}'"
          end
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

    protected

    def set_firebird_env(config)
      ENV['ISC_USER']     = config['username'].to_s if config['username']
      ENV['ISC_PASSWORD'] = config['password'].to_s if config['password']
    end

    def firebird_db_string(config)
      FireRuby::Database.db_string_for(config.symbolize_keys)
    end

    def set_psql_env(config)
      ENV['PGHOST']     = config['host']          if config['host']
      ENV['PGPORT']     = config['port'].to_s     if config['port']
      ENV['PGPASSWORD'] = config['password'].to_s if config['password']
      ENV['PGUSER']     = config['username'].to_s if config['username']
    end


  end
end
