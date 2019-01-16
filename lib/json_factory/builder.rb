# frozen_string_literal: true

module JSONFactory
  class Builder
    def initialize(template, local_variables = {})
      @io = StringIO.new
      @template = template
      @local_variables = local_variables
    end

    def context
      @local_variables
    end

    def build(execution_context = nil)
      json_builder = JSONBuilder.new(@io, :value, execution_context)
      if File.exist?(@template)
        json_builder.render_template(@template, @local_variables)
      else
        json_builder.render_string(@template, @local_variables)
      end
      @io.string
    end
  end
end
