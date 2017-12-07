module JSONFactory
  class JSONObject
    attr_reader :json_builder
    attr_accessor :context

    @@partials = {}

    def initialize(json_builder, context = nil)
      @json_builder = json_builder
      @context = context
    end

    def open_object
      json_builder.stream.push_object
    end

    def close_object
      json_builder.stream.pop
    end

    def schema!(object = nil)
      yield self, object
      self
    end

    def object!(key = nil, &block)
      json_object = JSONObject.new(json_builder)

      json_builder.stream.push_key(key.to_s) if key

      json_object.open_object
      json_object.schema!(&block)
      json_object.close_object
    end

    def array!(array, key = nil, &block)
      json_builder.stream.push_array(key ? key.to_s : nil)
      array.each do |object|
        builder = JSONObject.new(json_builder)
        builder.open_object
        builder.schema!(object, &block)
        builder.close_object
      end
      json_builder.stream.pop
    end

    def member!(key, value = nil)
      json_builder.stream.push_value(value, key.to_s)
    end

    def null!
      json_builder.output.seek(json_builder.output.pos - 1)
      json_builder.output.puts('null')
    end

    def cache!(cache_key, &block)
      json = json_builder.cache.read(cache_key) if cache_key && json_builder.cache
      return json_builder.output.puts(json) unless json.blank?

      start_cache_pos = json_builder.output.pos
      self.schema!(&block)
      end_cache_pos = json_builder.output.pos

      json_builder.cache.write(cache_key, json_builder.output.string[start_cache_pos..end_cache_pos])
    end

    def partial!(path, data = {})
      path = Pathname.new(path)

      if path.extname.eql?('.jfactory')
        @@partials[path] ||= File.open(path).read
      else
        @@partials[path] ||= File.open("#{path.dirname}/_#{path.basename}.jfactory").read
      end

      JSONObject.new(json_builder, JSONFactory::Context.new(data)).schema! do |json|
        json.instance_eval(@@partials[path])
      end
    end

    def method_missing(method_name, *arguments, &block)
      return context.send(method_name) if context.respond_to?(method_name)
      super
    end
  end
end
