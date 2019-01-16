# frozen_string_literal: true

require 'json'

module JSONFactory
  module Converter
    def self.json_key(object)
      json_value(object.to_s)
    end

    def self.json_value(object)
      raise "don't know how to convert #{object.inspect} (#{object.class})" unless object.respond_to?(:to_json)

      object.to_json
    end
  end
end
