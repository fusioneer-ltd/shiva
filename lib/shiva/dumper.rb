# -*- encoding : utf-8 -*-
require 'shiva/database'
require 'active_record/schema_dumper'

class Shiva::Dumper
  def self.dump database
    File.open(File.join(Rails.root, database.schema_path), 'w') do |file|
      ActiveRecord::SchemaDumper.dump database.base_model.connection, file
    end
  end
end
