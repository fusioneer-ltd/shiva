source 'https://rubygems.org'

# Specify your gem's dependencies in shiva.gemspec
gemspec

# Allows stuff like `rails=3.0.1 bundle install` or `rails=master ...`.
# Used by the CI.
dep = case ENV['rails']
      when 'stable', nil then nil
      when /(\d+\.)+\d+/ then "~> " + ENV['rails'].sub('rails-', '')
      else {github: 'rails/rails', branch: 'master'}
      end
gem 'activesupport', dep.dup
gem 'activerecord', dep.dup
gem 'activemodel', dep.dup
gem 'railties', dep.dup
gem 'rspec'
unless ENV['CI']
  gem 'simplecov', require: 'false'
end
if defined?(JRUBY_VERSION)
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbc-adapter', github: 'jruby/activerecord-jdbc-adapter'
  gem 'activerecord-jdbcsqlite3-adapter', github: 'jruby/activerecord-jdbc-adapter'
  gem 'jdbc-jtds'
else
  gem 'sqlite3'
end
