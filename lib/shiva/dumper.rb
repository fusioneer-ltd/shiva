# -*- encoding : utf-8 -*-
require 'shiva/database'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_record/schema_dumper'

class Shiva::Dumper
  def self.dump database
    path = defined?(Rails) ? Rails.root : Dir.getwd
    File.open(File.join(path, database.schema_path), 'w') do |file|
      ActiveRecord::SchemaDumper.dump database.base_model.connection, file
    end
  end
end
