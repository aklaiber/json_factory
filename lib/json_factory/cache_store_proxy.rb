# frozen_string_literal: true

module JSONFactory
  module CacheStoreProxy
    PROXIES = [RedisStoreProxy, MemoryStoreProxy, FileStoreProxy].freeze

    def self.build(store)
      store_proxy = PROXIES.find { |proxy| proxy.handle?(store) }
      fail CacheError, "#{store.class} is a not supported cache" if store_proxy.nil?
      store_proxy.new(store)
    end
  end
end
