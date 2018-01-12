# frozen_string_literal: true

module JSONFactory
  class State
    attr_accessor :io, :type, :count

    def initialize(io, type, count = 0)
      @io = io
      @type = type
      @count = count
    end
  end
end
