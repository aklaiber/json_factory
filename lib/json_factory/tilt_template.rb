# frozen_string_literal: true
require 'byebug'

module JSONFactory
  class TiltTemplate < Tilt::Template
    def self.metadata
      @metadata ||= { mime_type: "application/json" }
    end

    def render(scope=nil, locals={}, &block)
      scope ||= Object.new
      current_template = Thread.current[:tilt_current_template]
      Thread.current[:tilt_current_template] = self
      evaluate(scope, locals || {}, &block)
    ensure
      Thread.current[:tilt_current_template] = current_template
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      # locals_keys = locals.keys
      # locals_keys.sort!{|x, y| x.to_s <=> y.to_s}
      #
      # method = compiled_method(locals_keys)
      # method.bind(scope).call(locals, &block)
      JSONFactory.build(data, locals)
    end
  end
end
