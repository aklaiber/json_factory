# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_factory/version'

Gem::Specification.new do |spec|
  spec.name          = 'json_factory'
  spec.version       = JSONFactory::VERSION
  spec.authors       = ['Alexander Klaiber']
  spec.email         = ['alex.klaiber@gmail.com']

  spec.summary       = 'JSON schma to json'
  spec.description   = 'JSON schma to json'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 5.1.0'
  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'redis-activesupport', '>= 5.0.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'forgery'
  spec.add_development_dependency 'jbuilder'
  spec.add_development_dependency 'json-schema'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
