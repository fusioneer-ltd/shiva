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
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
