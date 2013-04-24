# -*- encoding : utf-8 -*-
require 'rubygems'
require 'simplecov_helper'
require File.join(File.dirname(__FILE__), '..', 'lib' ,'shiva')
require 'config'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/*.rb')].each {|f| require f}

require 'rspec/autorun'
