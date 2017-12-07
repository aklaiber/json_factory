# frozen_string_literal: true

module JSONFactory
  module CacheStoreProxy
    class FileStoreProxy < BaseStoreProxy
      STORE_CLASS = ActiveSupport::Cache::FileStore.freeze
    end
  end
end
