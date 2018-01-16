# frozen_string_literal: true

module JSONFactory
  class BuilderError < StandardError
  end

  class TypeNotAllowedError < BuilderError
  end

  class EmptyValueError < BuilderError
  end
end
