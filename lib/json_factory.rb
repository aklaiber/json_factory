# frozen_string_literal: true

require 'active_support'
require 'active_support/cache/redis_store'

require 'json_factory/railtie' if defined?(Rails)

require_relative 'json_factory/version'
require_relative 'json_factory/context'
require_relative 'json_factory/errors'
require_relative 'json_factory/state'
require_relative 'json_factory/converter'
require_relative 'json_factory/dsl'
require_relative 'json_factory/dsl/object_array'
require_relative 'json_factory/template_store'
require_relative 'json_factory/json_builder'

module JSONFactory
  autoload :Cache, 'json_factory/cache'
  autoload :TemplateStore, 'json_factory/template_store.rb'

  class Builder
    def initialize(template, local_variables = {})
      @io = StringIO.new
      @template = template
      @local_variables = local_variables
    end

    def context
      @local_variables
    end

    def build
      json_builder = JSONBuilder.new(@io)
      if @template.is_a?(String)
        json_builder.render_string(@template, @local_variables)
      elsif @template.is_a?(Pathname)
        json_builder.render_template(@template, @local_variables)
      end
      @io.string
    end
  end

  def self.build(template, local_variables = {})
    Builder.new(template, local_variables).build
  end
end
