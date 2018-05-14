# frozen_string_literal: true

require_relative 'dsl/object_array'
require_relative 'dsl/object_if'

module JSONFactory
  class DSL
    def self.check_arity(argc, expected)
      return if expected === argc # rubocop:disable Style/CaseEquality
      raise ArgumentError, "wrong number of arguments (given #{argc}, expected #{expected})"
    end

    def initialize(builder)
      @builder = builder
    end

    # :call-seq:
    #   json.value(value) -> nil
    #
    # Generates a JSON value.
    #
    #    json.value 1     # generates: 1
    #    json.value nil   # generates: null
    #    json.value :foo  # generates: "foo"
    def value(value)
      warn 'given block not used' if block_given?
      @builder.value(value)
    end

    # :call-seq:
    #   json.array           -> nil
    #   json.array { block } -> nil
    #
    # Generates a JSON array structure.
    #
    # The block is evaluated in order to add element to the array.
    #
    # If no block is given, an empty array is generated.
    #
    #    json.array
    #    # generates: []
    #
    #    json.array do
    #      json.element 1
    #      json.element 2
    #    end
    #    # generates: [1,2]
    def array(&block)
      @builder.array(&block)
    end

    # :call-seq:
    #   json.element(value)    -> nil
    #   json.element { block } -> nil
    #
    # Adds a value to a JSON array. Results in an exception if called outside an
    # array.
    #
    # If an argument is given, it is used as the element's value.
    #
    # If a block is given, it is evaluated in order to add nested structures.
    #
    #    json.array do
    #      json.element 1
    #      json.element 2
    #      json.element do
    #        json.array do
    #          json.element 3
    #          json.element 4
    #        end
    #      end
    #    end
    #    # generates: [1,2,[3,4]]
    def element(*args)
      if block_given?
        DSL.check_arity(args.length, 0..1)
        warn 'block supersedes value argument' if args.length == 1 && block_given?
        @builder.element { yield }
      else
        DSL.check_arity(args.length, 1)
        @builder.element(*args)
      end
    end

    # :call-seq:
    #   json.object           -> nil
    #   json.object { block } -> nil
    #
    # Generates a JSON object structure.
    #
    # The block is evaluated in order to add key-value pairs to the object.
    #
    # If no block is given, an empty object is generated.
    #
    #    json.object
    #    # generates: {}
    #
    #    json.object do
    #      json.member :foo, 1
    #      json.member :bar, 2
    #    end
    #    # generates: {"foo":1,"bar":2}
    def object
      if block_given?
        @builder.object { yield }
      else
        @builder.object
      end
    end

    # :call-seq:
    #   json.member(key, value)    -> nil
    #   json.member(key) { block } -> nil
    #
    # Adds a key-value pair to a JSON object. Results in an exception if called
    # outside an object.
    #
    # The first argument is used as the key. If a second argument is given, it
    # is used as the member's value.
    #
    # If a block is given, it is evaluated in order to add nested structures.
    #
    #    json.object do
    #      json.member :foo, 1
    #      json.member :bar, 2
    #      json.member :baz do
    #        json.array do
    #          json.element 3
    #          json.element 4
    #        end
    #      end
    #    end
    #    # generates: {"foo":1,"bar":2,"baz":[3,4]}
    def member(*args)
      if block_given?
        DSL.check_arity(args.length, 1..2)
        warn 'block supersedes value argument' if args.length == 2 && block_given?
        @builder.member(*args) { yield }
      else
        DSL.check_arity(args.length, 2)
        @builder.member(*args)
      end
    end

    # :call-seq:
    #   json.cache(key) { block } -> nil
    #
    # Caches the given content under the specified key.
    #
    # If a cache entry is found, it is added to the output. Otherwise, the given
    # block is evaluated and the result is stored in the cache.
    #
    #    json.object do
    #      json.member :foo, 1
    #      cache 'test-key' do
    #        json.member :bar, 2   # will be stored in the cache
    #      end
    #      cache 'test-key' do
    #        json.member :baz, 3   # will be ignored
    #      end
    #    end
    #    # generates: {"foo":1,"bar":2,"bar":2}
    #
    # When caching object members or array elements, commas are inserted as
    # needed. However, no further checks are performed, so improper use may
    # result in invalid JSON, for example by adding cached object members to an
    # array.
    def cache(key)
      @builder.cache(key) { yield }
    end

    # :call-seq:
    #   json.partial(file, local_variables = {})
    #
    # Loads the given partial and evaluates it using the local variables.
    #
    #    # simple.jfactory
    #    json.object do
    #      json.member :name, name
    #    end
    #
    #    json.array do
    #      json.element do
    #        json.partial 'simple.jfactory', name: 'foo'
    #      end
    #      json.element do
    #        json.partial 'simple.jfactory', name: 'bar'
    #      end
    #    end
    #    # generates: [{"name":"foo"},{"name":"bar"}]
    #
    # Partial files are loaded only once to minimize file access.
    def partial(file, local_variables = {})
      path = Pathname.new(File.expand_path(file))
      path = "#{path.dirname}/_#{path.basename}.jfactory" if path.extname.empty?
      @builder.partial(path.to_s, local_variables)
    end
  end
end
