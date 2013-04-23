source 'https://rubygems.org'

# Specify your gem's dependencies in shiva.gemspec
gemspec

# Allows stuff like `tilt=1.2.2 bundle install` or `tilt=master ...`.
# Used by the CI.
github = "git://github.com/%s.git"

dep = case ENV['rails']
      when 'stable', nil then nil
      when /(\d+\.)+\d+/ then "~> " + ENV['rails'].sub('rails-', '')
      else {git: (github % 'rails/rails'), branch: 'master'}
      end
gem 'activesupport', dep
gem 'activerecord', dep
gem 'activemodel', dep
gem 'railties', dep
gem 'rspec'
unless ENV['CI']
  gem 'simplecov', require: 'false'
end
if defined?(JRUBY_VERSION)
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbc-adapter', git: (github % 'jruby/activerecord-jdbc-adapter')
  gem 'activerecord-jdbcsqlite3-adapter', git: (github % 'jruby/activerecord-jdbc-adapter')
  gem 'jdbc-jtds'
else
  gem 'sqlite3'
end
