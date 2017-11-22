# frozen_string_literal: true

module JSONFactory
  module CacheStoreProxy
    class RedisStoreProxy < BaseStoreProxy
      STORE_CLASS = ActiveSupport::Cache::RedisStore.freeze
    end
  end
end
