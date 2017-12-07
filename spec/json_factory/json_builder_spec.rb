# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::JSONBuilder do
  let(:test_object_1) { OpenStruct.new(id: '001', name: 'TestObject1', description: 'Test1') }
  let(:test_object_2) { OpenStruct.new(id: '002', name: 'TestObject2', description: 'Test2') }
  let(:test_object) { OpenStruct.new(id: '1', name: 'TestObject2', description: 'Test2', test_objects: [test_object_1, test_object_2]) }

  describe 'top level object schema' do
    context 'with factory string' do
      let(:partial_1_file_path) { build_factory_file(partial_1) }
      let(:partial_2_file_path) { build_factory_file(partial_2) }

      let(:partial_1) do
        <<-RUBY
          json.member!(:id, test_object.id)
          json.member!(:name, test_object.name)
          json.object!(:sub_object) do |json|
            json.partial!('#{partial_2_file_path}')
          end
        RUBY
      end

      let(:partial_2) do
        <<-RUBY
          json.null!
        RUBY
      end

      let(:factory) do
        <<-RUBY
          json.object! do |json|
            json.member!(:meta, nil)
            json.object!(:data) do |json|
              json.member!(:id, object.id)

              json.object!(:test_object) do |json|
                json.member!(:test, "test")
                json.partial!('#{partial_1_file_path}', test_object: object)
              end

              json.object!(:test_null) do |json|
                json.null!
              end

              json.array!(object.test_objects, :test_array) do |json, test_object|
                json.member!(:name, test_object.name)
                json.member!(:description, test_object.description)
              end
            end
          end
        RUBY
      end


      let(:context) { JSONFactory::Context.new(object: test_object) }
  
      subject { JSONFactory::JSONBuilder.new(factory) }
  
      it 'builds json' do
        expect(subject.build(context)).to match_response_schema('object_schema.json')
      end
    end
  end

  describe 'top level array schema' do
    context 'with factory string' do
      let(:factory) do
        <<-RUBY
          json.array! objects do |json, test_object|
            json.member!(:id, test_object.id)
            json.member!(:name, test_object.name)
            json.member!(:description, test_object.description)
          end
        RUBY
      end

      let(:context) { JSONFactory::Context.new(objects: [test_object_1, test_object_2]) }

      subject { JSONFactory::JSONBuilder.new(factory) }

      it 'builds json' do
        expect(subject.build(context)).to match_response_schema('top_level_array_schema.json')
      end
    end
  end

  describe '.load_factory' do
    let(:factory) do
      <<-RUBY
        json.object! do |json|
          json.member!(:id, 'test-id')
        end
      RUBY
    end

    subject { JSONFactory::JSONBuilder.load_factory_file(build_factory_file(factory)) }

    it 'builds json' do
      expect(subject.build).to eql('{"id":"test-id"}')
    end
  end

  describe '#cache!' do
    let(:store) { ActiveSupport::Cache::MemoryStore.new }
    let(:factory) do
      <<-RUBY
        json.object! do |json|
          json.member!(:id1, 'id 1')
          json.member!(:id2, 'id 2')
          json.cache! 'test-cache-key' do |json|
            json.member!(:id3, 'id 3')
          end

          json.cache! 'test-cache-key-for-test_object' do |json|
            json.object!(:test_object) do |json|
              json.member!(:test, "test")
            end
          end
        end
      RUBY
    end

    before do
      builder = JSONFactory::JSONBuilder.new(factory)
      builder.cache.store = store
      builder.build
    end

    let(:cache) { JSONFactory::Cache.instance }
    subject { JSONFactory::JSONBuilder.new(factory) }

    before do
      subject.cache.store = store
    end

    it 'returns cached json' do
      expect_any_instance_of(JSONFactory::Cache).to receive(:read).twice.and_call_original
      expect(subject.build).to eql('{"id1":"id 1","id2":"id 2","id3":"id 3","test_object":{"test":"test"}}')
    end
  end

  describe 'load partial factory file' do
    let(:factory) do
      <<-RUBY
        json.object! do |json|
          json.partial!('/Users/aklaiber/Workspace/json_factory/spec/fixtures/test_partial')
        end
      RUBY
    end

    subject { JSONFactory::JSONBuilder.new(factory) }

    it { expect(subject.build).to eql('{"id":"id 1"}') }
  end
end
