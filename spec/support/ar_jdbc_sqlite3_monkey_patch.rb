# -*- encoding : utf-8 -*-
if defined?(JRUBY_VERSION)
  require 'arjdbc'
  require 'arjdbc/sqlite3'
  ArJdbc::SQLite3.module_eval do
    def indexes(table_name, name = nil) # :nodoc:
      exec_query("PRAGMA index_list(#{quote_table_name(table_name)})", 'SCHEMA').map do |row|
        name = row['name']
        unique = row['unique'] != 0
        columns = exec_query("PRAGMA index_info('#{name}')", 'SCHEMA').map { |col| col['name'] }
        ArJdbc::SQLite3::IndexDefinition.new(table_name, name, unique, columns)
      end
    end
  end
end
