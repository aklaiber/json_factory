# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::CacheStoreProxy do
  @cache_stores = [
    ActiveSupport::Cache::MemoryStore.new,
    ActiveSupport::Cache::RedisStore.new('127.0.0.1')
  ]

  @cache_stores.each do |store|
    describe "with #{store.class}" do
      subject(:cache_store_proxy) { JSONFactory::CacheStoreProxy.build(store) }

      it 'builds store proxy' do
        expect(cache_store_proxy.store).to be_kind_of(store.class)
      end
    end
  end
end
