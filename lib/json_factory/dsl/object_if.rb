# frozen_string_literal: true

module JSONFactory
  class DSL
    # Helper method to generate an object.
    #
    #   json.object_if(true) do |id|
    #     json.member :foo, 'bar'
    #   end
    #   # generates: {"foo":"bar"}
    #
    #   json.object_if(false) do |id|
    #     json.member :foo, 'bar'
    #   end
    #   # generates: null
    def object_if(value, &block)
      value ? object(&block) : value(nil)
    end
  end
end
