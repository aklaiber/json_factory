# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::Cache do
  @cache_stores = [
    ActiveSupport::Cache::MemoryStore.new,
    ActiveSupport::Cache::RedisStore.new('127.0.0.1')
  ]

  @cache_stores.each do |store|
    describe "with #{store.class}" do
      before do
        subject.store = store
      end

      it 'builds store proxy' do
        expect(subject.store_proxy.store).to be_kind_of(store.class)
      end
    end
  end
end
