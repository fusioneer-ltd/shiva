# -*- encoding : utf-8 -*-
class Shiva::Configurator
  def database(base_model, name = friendly_name_for_base_model(base_model))
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
