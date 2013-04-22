# -*- encoding : utf-8 -*-
module Shiva
  class Database
    attr_accessor :base_model_name, :name

    def migration_path
      "db/migrate/#{name}/"
    end

    def schema_path
      "db/schema/#{name}_schema.rb"
    end

    def structure_path
      "db/schema/#{name}_structure.sql"
    end

    def seeds_path
      "db/seeds/#{name}.rb"
    end

    def base_model
      base_model_name.constantize
    end

    private
    def initialize base_model, name
      self.base_model_name = base_model
      self.name            = name
    end
  end
end
