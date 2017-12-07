# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::Cache do
  subject { JSONFactory::Cache.instance }

  @cache_stores = [
    ActiveSupport::Cache::MemoryStore.new,
    ActiveSupport::Cache::FileStore.new('tmp'),
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

  context 'with unsupported cache' do
    let(:unkown_cache_class) do
      Class.new do
      end
    end

    it { expect { subject.store = unkown_cache_class }.to raise_error JSONFactory::CacheError, 'Class is a not supported cache' }
  end
end
