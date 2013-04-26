module Shiva
  class LegacyTasks

    # poor, poor Rails 3...


    # ActiveRecord 3 structure load task
    def self.structure_load(database, filename)
      config = database.config
      case config['adapter']
      when /mysql/
        database.base_model.connection.execute('SET foreign_key_checks = 0')
        IO.read(filename).split("\n\n").each do |table|
          database.base_model.connection.execute(table)
        end
      when /postgresql/
        set_psql_env(config)
        `psql -f "#{filename}" #{config['database']}`
      when /sqlite/
        dbfile = config['database']
        `sqlite3 #{dbfile} < "#{filename}"`
      when 'sqlserver'
        `sqlcmd -S #{config['host']} -d #{config['database']} -U #{config['username']} -P #{config['password']} -i #{filename}`
      when 'oci', 'oracle'
        IO.read(filename).split(";\n\n").each do |ddl|
          database.base_model.connection.execute(ddl)
        end
      when 'firebird'
        set_firebird_env(config)
        db_string = firebird_db_string(config)
        sh "isql -i #{filename} #{db_string}"
      else
        raise TaskNotSupportedError.new("Task not supported by '#{config['adapter']}'")
      end
    end

    # ActiveRecord 3 structure dump task
    def self.structure_dump(database, filename)
      config = database.config
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
        raise TaskNotSupportedError.new("Task not supported by '#{config['adapter']}'")
      end
    end

    protected

    def self.set_firebird_env(config)
      ENV['ISC_USER']     = config['username'].to_s if config['username']
      ENV['ISC_PASSWORD'] = config['password'].to_s if config['password']
    end

    def self.firebird_db_string(config)
      FireRuby::Database.db_string_for(config.symbolize_keys)
    end

    def self.set_psql_env(config)
      ENV['PGHOST']     = config['host']          if config['host']
      ENV['PGPORT']     = config['port'].to_s     if config['port']
      ENV['PGPASSWORD'] = config['password'].to_s if config['password']
      ENV['PGUSER']     = config['username'].to_s if config['username']
    end
  end

  class TaskNotSupportedError < StandardError
  end

end
