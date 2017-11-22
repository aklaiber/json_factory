# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::CacheStoreProxy::MemoryStoreProxy do
  let(:store) { ActiveSupport::Cache::MemoryStore.new }
  subject { JSONFactory::CacheStoreProxy::MemoryStoreProxy.new(store) }

  it_behaves_like 'a cache store proxy'
end
