# -*- encoding : utf-8 -*-
module RailsCompatibility
  module Includes

    def catch_no_support(&block)
      yield
    rescue => e
      # ActiveRecord::Tasks is only defined in Rails 4
      # and since we're testing all possible Rails versions
      # we do not fail, if it's not defined
      if e.is_a?(Shiva::TaskNotSupportedError) || defined?(ActiveRecord::Tasks::DatabaseNotSupported) && e.is_a?(ActiveRecord::Tasks::DatabaseNotSupported)
        pending e.message
      else
        raise e
      end
    end
  end
end

RSpec.configure do |config|
  config.include RailsCompatibility::Includes
end
