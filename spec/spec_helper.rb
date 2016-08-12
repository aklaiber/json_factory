# frozen_string_literal: true
require 'ostruct'
require 'json-schema'

require_relative '../lib/json_factory'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

FIXTURES = "#{File.dirname(__FILE__)}/fixtures"

RSpec.configure do |config|
  config.include(JsonFactoryFileHelpers)
end
