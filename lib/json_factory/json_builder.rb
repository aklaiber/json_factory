# frozen_string_literal: true

module JSONFactory
  class JSONBuilder
    attr_accessor :output
    attr_reader :stream, :factory, :cache, :context

    def self.load_factory_file(path, context = nil)
      raise "file format is invalid. #{path}" unless File.extname(path).eql?('.jfactory')
      raise "jfactory file #{path} not found" unless File.exist?(path)
      new(File.open(path).read, context)
    end

    def initialize(factory, context = nil)
      @factory = factory
      @cache = Cache.instance
      @context = context
    end

    def build
      @output  =  StringIO.new
      @stream  = Oj::StreamWriter.new(@output, indent: 0)

      JSONObject.new(self, @context).schema! { |json|
        json.instance_eval(@factory)
      }

      @output.string.delete("\n").gsub('null}', 'null') if @output
    end
  end
end
