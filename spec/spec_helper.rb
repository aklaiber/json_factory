# frozen_string_literal: true

require 'ostruct'
require 'json-schema'
require 'json_factory'

require_relative 'support/helpers/json_factory_file_helpers'
require_relative 'support/matchers/api_schema_matcher'
require_relative 'support/shared_examples/shared_examples_for_cache_store_proxy'

FIXTURES = "#{File.dirname(__FILE__)}/fixtures"

RSpec.configure do |config|
  config.include(JsonFactoryFileHelpers)
end
