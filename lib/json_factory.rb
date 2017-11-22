# frozen_string_literal: true

require 'oj'

require 'active_support'
require 'active_support/cache/redis_store'

require_relative 'json_factory/version'
require_relative 'json_factory/context'
require_relative 'json_factory/json_builder'

module JSONFactory
  autoload :Cache,            'json_factory/cache.rb'
  autoload :CacheStoreProxy,  'json_factory/cache_store_proxy.rb'
  autoload :BaseStoreProxy,   'json_factory/cache_store_proxy/base_store_proxy.rb'
  autoload :RedisStoreProxy,  'json_factory/cache_store_proxy/redis_store_proxy.rb'
  autoload :MemoryStoreProxy, 'json_factory/cache_store_proxy/memory_store_proxy.rb'
end
