# frozen_string_literal: true

module JSONFactory
  class JSONBuilder
    attr_accessor :output
    attr_reader :stream, :factory, :cache

    def self.load_factory_file(path)
      raise "file format is invalid. #{path}" unless File.extname(path).eql?('.jfactory')
      raise "jfactory file #{path} not found" unless File.exist?(path)
      new(File.open(path).read)
    end

    def initialize(factory)
      @factory = factory
      @cache = Cache.instance
    end

    def build(context = nil)
      @output  =  StringIO.new
      @stream  = Oj::StreamWriter.new(@output, indent: 0)

      JSONObject.new(self, context).schema! { |json|
        json.instance_eval(@factory)
      }

      @output.string.delete("\n").gsub('null}', 'null') if @output
    end
  end
end
