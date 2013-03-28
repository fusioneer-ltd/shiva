# -*- encoding : utf-8 -*-
if ENV['COVERAGE']
  require 'simplecov'
  require 'simplecov-html'
  require 'support/fix_simplecov'

  SimpleCov.minimum_coverage 99.7
  SimpleCov.start do
    add_filter 'Gemfile' # Why would we want the Gemfile coverage ?!
    add_filter 'spec'

    # Define a group for the extras folder
    add_group 'Shiva', 'lib/shiva/|shiva.rb'
    add_group 'Tasks', 'lib/tasks/'
  end
end
