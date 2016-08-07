# frozen_string_literal: true
module JSONFactory
  class Context
    attr_reader :objects

    def initialize(objects)
      @objects = objects
    end

    def method_missing(method_name, *arguments, &block)
      return objects[method_name] if objects.key?(method_name)
      super
    end

    def respond_to_missing?(method_name, include_private = false)
      objects.key?(method_name) || super
    end
  end
end
