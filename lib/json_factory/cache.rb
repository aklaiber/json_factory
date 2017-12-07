# frozen_string_literal: true

module JSONFactory
  class Cache
    include Singleton

    attr_accessor :prefix

    def initialize
      @prefix = 'json_factory'

      self.store = ::Rails.cache if defined?(::Rails.cache)
    end

    attr_reader :store
    alias store_proxy store

    def store=(store)
      @store = CacheStoreProxy.build(store)
    end

    delegate :read, to: :store
    delegate :write, to: :store
    delegate :delete, to: :store
  end
end
