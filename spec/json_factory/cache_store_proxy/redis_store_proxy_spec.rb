# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::CacheStoreProxy::RedisStoreProxy do
  let(:store) { ActiveSupport::Cache::RedisStore.new('127.0.0.1', db: 10) }
  subject { JSONFactory::CacheStoreProxy::RedisStoreProxy.new(store) }

  it_behaves_like 'a cache store proxy'
end
