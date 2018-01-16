# frozen_string_literal: true

module JSONFactory
  class TemplateStore
    include Singleton

    def initialize
      @templates = {}
    end

    def get(path)
      if @templates.key? path
        @templates.fetch(path)
      else
        @templates.store(path, read_template(path))
      end
    end

    def clear
      @templates.clear
    end

    private

    def read_template(path)
      raise "file format is invalid. #{path}" unless File.extname(path).eql?('.jfactory')
      raise "jfactory file #{path} not found" unless File.exist?(path)
      File.read(path)
    end
  end
end
