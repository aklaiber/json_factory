# frozen_string_literal: true

module JSONFactory
  module CacheStoreProxy
    PROXIES = [RedisStoreProxy, MemoryStoreProxy].freeze

    def self.build(store)
      PROXIES.find { |proxy| proxy.handle?(store) }.new(store)
    end
  end
end
