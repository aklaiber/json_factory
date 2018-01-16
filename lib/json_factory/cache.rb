# frozen_string_literal: true

module JSONFactory
  class Cache
    include Singleton
    attr_accessor :store, :prefix

    def initialize
      @prefix = 'json_factory'
    end

    def transform_key(key)
      [prefix, key].compact.join(':')
    end

    def fetch(key, options = nil, &block)
      store.fetch(transform_key(key), options, &block)
    end
  end
end
