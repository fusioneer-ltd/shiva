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
gem 'activesupport', dep && dep.dup
gem 'activerecord', dep && dep.dup
gem 'activemodel', dep && dep.dup
gem 'railties', dep && dep.dup
gem 'rspec'
unless ENV['CI']
  gem 'simplecov', require: 'false'
end
if defined?(JRUBY_VERSION)
  case ENV['DB']
  when /mssql/
    gem 'activerecord-jdbc-adapter'
    gem 'activerecord-jdbcmssql-adapter'
    gem 'jdbc-jtds'
  when /^(mysql|postgresql)$/
    gem 'activerecord-jdbc-adapter', github: 'jruby/activerecord-jdbc-adapter'
    gem "activerecord-jdbc#{ENV['DB']}-adapter", github: 'jruby/activerecord-jdbc-adapter'
  else
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbc-adapter', github: 'jruby/activerecord-jdbc-adapter'
    gem 'activerecord-jdbcsqlite3-adapter', github: 'jruby/activerecord-jdbc-adapter'
  end
else
  case ENV['DB']
  when /mssql/
    gem 'activerecord-sqlserver-adapter', github: 'jruby/activerecord-jdbc-adapter'
  when /mysql/
    gem 'mysql2'
  when /postgres/
    gem 'pg'
  else
    gem 'sqlite3'
  end
  gem 'sqlite3'
end
