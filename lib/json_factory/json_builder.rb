# frozen_string_literal: true

module JSONFactory
  class JSONBuilder
    attr_reader :attributes, :factory, :cache
    attr_accessor :context

    @@partials = {}

    @json = nil
    @cache_key = nil

    def initialize(factory = nil, data = {})
      @attributes = {}
      @factory = factory
      @context = Context.new(data)
      @cache = Cache.new

      init_factory if factory && !data.empty?
    end

    def init_factory
      schema do |json|
        json.instance_eval(factory)
      end
    end

    def self.load_factory_file(path, data = {})
      raise "file format is invalid. #{path}" unless File.extname(path).eql?('.jfactory')
      raise "jfactory file #{path} not found" unless File.exist?(path)
      new(File.open(path).read, data)
    end

    def data=(data)
      @context.data = data
      init_factory
    end

    def schema(object = nil, &block)
      return self unless block_given?
      if object
        if object.is_a?(Array)
          collection(object, &block)
        else
          yield self, object
        end
      else
        yield self
      end
      self
    end

    def cache!(key)
      @cache_key = key
      @json = @cache.read(@cache_key) if @cache_key && @cache
      yield self
    end

    def partial!(factory, data = {})
      if factory.include?('.jfactory')
        @@partials[factory] ||= self.class.load_factory_file(factory)
        @@partials[factory].data = data
        attributes.merge!(@@partials[factory].attributes)
      else
        attributes.merge!(self.class.new(factory, data).attributes)
      end
    end

    def method_missing(method_name, *arguments, &block)
      return set_value(method_name.to_s, arguments.at(0)) unless Kernel.block_given?
      return set_collection(method_name.to_s, arguments.at(0), &block) if arguments.at(0).is_a?(Array)
      set_object(method_name.to_s, &block)
    end

    def build
      @json = perform_builder if @json.nil?

      @cache.write(@cache_key, @json) if @cache_key && @cache

      @json
    end

    private

    def perform_builder
      init_factory if attributes.empty?
      Oj.dump(attributes)
    end

    def collection(collection, &block)
      @attributes = collection.map { |object| self.class.new.schema(object, &block).attributes }
    end

    def set_value(key, value)
      @attributes[key] = value
    end

    def set_object(key, &block)
      @attributes[key] = self.class.new.schema(&block).attributes
    end

    def set_collection(key, collection, &block)
      @attributes[key] = collection.map { |object| self.class.new.schema(object, &block).attributes }
    end
  end
end
