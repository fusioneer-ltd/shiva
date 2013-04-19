# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shiva/version'

Gem::Specification.new do |gem|
  gem.name          = 'shiva'
  gem.version       = Shiva::VERSION
  gem.authors       = ['Pierre Schambacher', 'Mike Połtyn']
  gem.email         = ['pschambacher@fusioneer.com', 'mpoltyn@fusioneer.com']
  gem.description   = %q{Add rake tasks to deal with several databases.}
  gem.summary       = <<-EOS
Rails and ActiveRecord aren't really meant to deal with several database at a time just out of the box.
Shiva extends the rake tasks (like migrate of schema:dump) to work with several databases.
This way you have a folder in db/migrate for each database, a separate schema.rb for each, etc.
EOS
  gem.homepage      = ''
  #gem.licence       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/}) + ['.rspec']
  gem.require_paths = ['lib']

  gem.add_dependency 'rake'
  if ENV['RAILS_3_0']
    gem.add_dependency 'activesupport', '~> 3.0.0'
    gem.add_dependency 'activerecord', '~> 3.0.0'
    gem.add_dependency 'activemodel', '~> 3.0.0'
  elsif ENV['RAILS_3_1']
    gem.add_dependency 'activesupport', '~> 3.1.0'
    gem.add_dependency 'activerecord', '~> 3.1.0'
    gem.add_dependency 'activemodel', '~> 3.1.0'
  elsif ENV['RAILS_3_2']
    gem.add_dependency 'activesupport', '~> 3.2.0'
    gem.add_dependency 'activerecord', '~> 3.2.0'
    gem.add_dependency 'activemodel', '~> 3.2.0'
  else
    # normal case
    gem.add_dependency 'activesupport', '>= 3.0.0'
    gem.add_dependency 'activerecord', '>= 3.0.0'
    gem.add_dependency 'activemodel', '>= 3.0.0'
  end
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  if defined?(JRUBY_VERSION)
    gem.add_development_dependency 'jdbc-sqlite3'
    gem.add_development_dependency 'activerecord-jdbc-adapter', '1.3.0DEV'
    gem.add_development_dependency 'activerecord-jdbcsqlite3-adapter', '1.3.0DEV'
    gem.add_development_dependency 'jdbc-jtds'
  else
    gem.add_development_dependency 'sqlite3'
    gem.add_development_dependency 'activerecord-sqlite3-adapter'
  end
end
