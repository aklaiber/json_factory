# frozen_string_literal: true

module JSONFactory
  class JSONBuilder
    BUILDER_VARIABLE_NAME = :json

    TOKEN_LEFT_SQUARE_BRACKET = '['
    TOKEN_RIGHT_SQUARE_BRACKET = ']'
    TOKEN_LEFT_CURLY_BRACKET = '{'
    TOKEN_RIGHT_CURLY_BRACKET = '}'
    TOKEN_COLON = ':'
    TOKEN_COMMA = ','

    def initialize(io, type = :value)
      @stack = [State.new(io, type)]
      @cache = Cache.instance
      @template_store = TemplateStore.instance
    end

    def value(value = nil)
      raise TypeNotAllowedError, 'Can only add value as a value' unless type == :value
      raise TypeNotAllowedError, 'Cannot add multiple values' unless count.zero?
      add_value(value)
      increment_count
    end

    def array
      raise TypeNotAllowedError, 'Can only add array as a value' unless type == :value
      raise TypeNotAllowedError, 'Cannot add multiple values' unless count.zero?

      io << TOKEN_LEFT_SQUARE_BRACKET
      push_type(:array) { yield } if block_given?
      io << TOKEN_RIGHT_SQUARE_BRACKET
      increment_count
    end

    def element(value = nil)
      raise TypeNotAllowedError, 'Can only add an element within an array' unless type == :array

      add_separator
      if block_given?
        push_type(:value) { yield }
      else
        add_value(value)
      end
      increment_count
    end

    def object
      raise TypeNotAllowedError, 'Can only add object as a value' unless type == :value
      raise TypeNotAllowedError, 'Cannot add multiple values' unless count.zero?

      io << TOKEN_LEFT_CURLY_BRACKET
      push_type(:object) { yield } if block_given?
      io << TOKEN_RIGHT_CURLY_BRACKET
      increment_count
    end

    def member(key, value = nil)
      raise TypeNotAllowedError, 'Can only add a member within an object' unless type == :object

      add_separator
      io << Converter.json_key(key)
      io << TOKEN_COLON
      if block_given?
        push_type(:value) { yield }
      else
        add_value(value)
      end
      increment_count
    end

    def cache(key)
      value = @cache.fetch(key) do
        cache_io = StringIO.new
        push_io(cache_io) { yield }
        cache_io.string
      end
      raise EmptyValueError if value.empty?

      add_separator
      io << value
      increment_count
    end

    def evaluate(string, local_variables, filename)
      dsl = DSL.new(self)
      binding = jfactory(dsl)
      local_variables.each_pair do |key, value|
        binding.local_variable_set(key, value)
      end
      binding.local_variable_set(BUILDER_VARIABLE_NAME, dsl)
      eval(string, binding, filename.to_s) # rubocop:disable Security/Eval
    end

    def render_template(filename, local_variables)
      template = @template_store.get(filename)
      evaluate(template, local_variables, filename)
    end
    alias partial render_template

    def render_string(string, local_variables)
      evaluate(string, local_variables, '(inline)')
    end

    private

    def add_value(value)
      io << Converter.json_value(value)
    end

    def add_separator
      io << TOKEN_COMMA unless count.zero?
    end

    def io
      @stack.last.io
    end

    def type
      @stack.last.type
    end

    def count
      @stack.last.count
    end

    def increment_count
      @stack.last.count += 1
    end

    def push_io(io)
      @stack.push(State.new(io, type))
      yield
      @stack.pop
    end

    def push_type(type)
      @stack.push(State.new(io, type))
      yield
      raise EmptyValueError if type == :value && count.zero?
      @stack.pop
    end
  end
end

JSONFactory::JSONBuilder.class_eval do
  # Returns an empty evaluation context, similar to Ruby's main object.
  def jfactory(__dsl__)
    Object.allocate.instance_eval do
      class << self
        JSONFactory.configure.helpers.each { |mod| include mod }

        def to_s
          'jfactory'
        end
        alias inspect to_s
      end

      define_singleton_method(:__dsl__) do
        __dsl__
      end

      def method_missing(method_name, *args, &block)
        if __dsl__.respond_to?(method_name)
          __dsl__.send(method_name, *args, &block)
        else
          super
        end
      end
      
      return binding
    end
  end
  private :jfactory
end
