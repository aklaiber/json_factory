# frozen_string_literal: true

module JSONFactory
  module CacheStoreProxy
    class MemoryStoreProxy < BaseStoreProxy
      STORE_CLASS = ActiveSupport::Cache::MemoryStore.freeze
    end
  end
end
