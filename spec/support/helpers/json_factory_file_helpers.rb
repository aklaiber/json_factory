# frozen_string_literal: true

module JsonFactoryFileHelpers
  def build_factory_file(factory)
    factory_file = Tempfile.new(%w[factory .jfactory])
    factory_file.write(factory)
    factory_file.rewind
    factory_file.path
  end
end
