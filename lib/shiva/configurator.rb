# -*- encoding : utf-8 -*-
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
module Shiva
  class Configurator
    def database(base_model = nil, name = nil)
      raise ArgumentError.new("You have to specify database name for Shiva!") if base_model.blank?
      if base_model.is_a?(Class)
        raise ArgumentError.new <<-ERROR
Due to possible preloading issues, please refrain from using classes in Shiva.
Use this snippet instead:
  Shiva.configure do
    database \"#{base_model.name}\"#{", \"#{name}\"" if name.present?}
  end
        ERROR
      end
      raise ArgumentError.new("Only strings are allowed as database names in Shiva configuration!") unless base_model.is_a?(String) && (name.nil? || name.is_a?(String))

      # Due to custom argument errors above, moved here from method definition
      name ||= friendly_name_for_base_model(base_model)

      @databases << Shiva::Database.new(base_model, name)
    end

    def _databases
      @databases
    end

    private
    def friendly_name_for_base_model base_model
      base_model.split('::').last.underscore
    end

    def initialize
      @databases = []
    end
  end
end
