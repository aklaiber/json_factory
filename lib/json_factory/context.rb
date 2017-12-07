# frozen_string_literal: true

module JSONFactory
  class Context
    def initialize(data = nil)
      @data = data
    end

    def add(key, value)
      @data[key] = value
    end

    def method_missing(method_name, *arguments, &block)
      return @data[method_name] if @data.is_a?(Hash) && @data.key?(method_name)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      (@data.is_a?(Hash) && @data.key?(method_name)) || super
    end
  end
end
