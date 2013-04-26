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
  when /mysql/
    gem 'activerecord-jdbc-adapter', github: 'jruby/activerecord-jdbc-adapter'
    gem "activerecord-jdbcmysql-adapter", github: 'jruby/activerecord-jdbc-adapter'
    gem 'jdbc-mysql', github: 'jruby/activerecord-jdbc-adapter'
  when /postgres/
    gem 'activerecord-jdbc-adapter', github: 'jruby/activerecord-jdbc-adapter'
    gem "activerecord-jdbcpostgresql-adapter", github: 'jruby/activerecord-jdbc-adapter'
    gem 'jdbc-postgres', github: 'jruby/activerecord-jdbc-adapter'
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
    mysql_version = case ENV['rails']
    when /3\.0\./ then '<0.3' # poor Rails 3.0 can't handle new mysql2 gem :(
    else nil
    end
    gem 'mysql2', mysql_version
  when /postgres/
    gem 'pg'
  else
    gem 'sqlite3'
  end
  gem 'sqlite3'
end
gem 'pry'
