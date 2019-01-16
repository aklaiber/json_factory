# frozen_string_literal: true

require 'active_support'
require 'active_support/cache/redis_store'

require 'json_factory/railtie' if defined?(Rails)

require_relative 'json_factory/version'
require_relative 'json_factory/configuration'
require_relative 'json_factory/errors'
require_relative 'json_factory/state'
require_relative 'json_factory/converter'
require_relative 'json_factory/dsl'
require_relative 'json_factory/template_store'
require_relative 'json_factory/json_builder'
require_relative 'json_factory/builder'

module JSONFactory
  autoload :Cache, 'json_factory/cache'
  autoload :TemplateStore, 'json_factory/template_store.rb'

  def self.build(template, local_variables = {}, execution_context = nil)
    Builder.new(template, local_variables).build(execution_context)
  end

  def self.configure
    if block_given?
      yield Configuration.instance
    else
      Configuration.instance
    end
  end
end
