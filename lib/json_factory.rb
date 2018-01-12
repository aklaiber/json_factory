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

  def self.build_template(filename, local_variables = {})
    StringIO.open do |io|
      JSONBuilder.new(io).render_template(filename, local_variables)
      io.string
    end
  end

  def self.build_string(string, local_variables = {})
    StringIO.open do |io|
      JSONBuilder.new(io).render_string(string, local_variables)
      io.string
    end
  end
end
