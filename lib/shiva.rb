# -*- encoding : utf-8 -*-
require 'shiva/version'
require 'shiva/configurator'
require 'shiva/database'

module Shiva
  def self.configure &block
    @configuration = Shiva::Configurator.new

    @configuration.instance_eval &block
  end

  def self.configuration
    raise 'You have to run Shiva.configure before using Shiva' if @configuration.blank?
    @configuration
  end
end

require 'rake'
Dir.glob(File.join(File.dirname(__FILE__), 'tasks','*.rake')).each { |r| import r }
