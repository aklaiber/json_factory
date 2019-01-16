# frozen_string_literal: true

module JSONFactory
  class TiltTemplate < Tilt::Template
    def self.metadata
      @metadata ||= { mime_type: 'application/json' }
    end

    def render(scope = nil, locals = {}, &block)
      # scope ||= Object.new
      current_template = Thread.current[:tilt_current_template]
      Thread.current[:tilt_current_template] = self
      evaluate(scope, locals || {}, &block)
    ensure
      Thread.current[:tilt_current_template] = current_template
    end

    def prepare; end

    def evaluate(scope, locals, &_block)
      JSONFactory.build(data, locals, scope)
    end
  end
end
