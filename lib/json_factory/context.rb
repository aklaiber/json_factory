# frozen_string_literal: true
module JSONFactory
  class Context
    attr_accessor :data

    def initialize(data)
      @data = data
    end

    def add(key, value)
      @data[key] = value
    end

    def method_missing(method_name, *arguments, &block)
      return data[method_name] if data.key?(method_name)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      data.key?(method_name) || super
    end
  end
end
