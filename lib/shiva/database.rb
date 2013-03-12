# -*- encoding : utf-8 -*-
class Shiva::Database
  attr_accessor :base_model, :name

  private
  def initialize base_model, name
    self.base_model = base_model
    self.name       = name
  end
end
