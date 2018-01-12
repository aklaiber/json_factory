# frozen_string_literal: true

require 'tempfile'

module JsonFactoryFileHelpers
  # Creates a temporary file with the given content and returns its path.
  # You have to unlink the file after using it.
  def build_factory_file(factory)
    ::Tempfile.open(%w[factory .jfactory]) do |f|
      f.write(factory)
      f.path
    end
  end
end
