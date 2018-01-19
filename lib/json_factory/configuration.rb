# frozen_string_literal: true

require 'singleton'

module JSONFactory
  class Configuration
    include Singleton

    attr_reader :helpers

    def initialize
      @helpers = []
    end

    def include_helper(mod)
      @helpers.push(mod)
    end
  end
end
