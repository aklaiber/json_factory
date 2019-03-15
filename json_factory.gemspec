# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_factory/version'

Gem::Specification.new do |spec|
  spec.name          = 'json_factory'
  spec.version       = JSONFactory::VERSION
  spec.author        = 'Alexander Klaiber'

  spec.summary       = 'JsonFactory is a easy DSL to create JSON structures with a development focus on performance.'
  spec.homepage      = 'https://github.com/aklaiber/json_factory'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'redis-activesupport', '>= 5.0.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'forgery'
  spec.add_development_dependency 'jbuilder'
  spec.add_development_dependency 'json-schema'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
