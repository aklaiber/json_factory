# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::CacheStoreProxy::FileStoreProxy do
  let(:store) { ActiveSupport::Cache::FileStore.new('tmp') }
  subject { JSONFactory::CacheStoreProxy::FileStoreProxy.new(store) }

  it_behaves_like 'a cache store proxy'
end
