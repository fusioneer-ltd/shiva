# -*- encoding : utf-8 -*-
class Shiva::Configurator
  def database base_model, name = base_model.name.split('::').last.underscore
    @databases << Shiva::Database.new(base_model, name)
  end

  def _databases
    @databases
  end

  private
  def initialize
    @databases = []
  end
end
