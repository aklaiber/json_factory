# frozen_string_literal: true

module JSONFactory
  module CacheStoreProxy
    class BaseStoreProxy
      attr_reader :store

      def self.handle?(store)
        defined?(self::STORE_CLASS) && store.is_a?(self::STORE_CLASS)
      end

      def initialize(store, prefix = 'json_factory')
        @store = store
        @prefix = prefix
      end

      def read(key, options = nil)
        store.read("#{@prefix}:#{key}", options)
      end

      def write(key, value, options = nil)
        store.write("#{@prefix}:#{key}", value, options)
      end

      def delete(key, options = nil)
        store.delete("#{@prefix}:#{key}", options)
      end
    end
  end
end
