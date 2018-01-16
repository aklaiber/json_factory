# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::JSONBuilder do
  let(:test_object_1) { OpenStruct.new(id: '001', name: 'TestObject1', description: 'Test1') }
  let(:test_object_2) { OpenStruct.new(id: '002', name: 'TestObject2', description: 'Test2') }
  let(:test_object) { OpenStruct.new(id: '1', name: 'TestObject2', description: 'Test2', test_objects: [test_object_1, test_object_2]) }

  describe 'top level object schema' do
    context 'with factory string' do
      after do
        File.unlink(partial_1_file_path, partial_2_file_path)
      end
      let(:partial_1_file_path) { build_factory_file(partial_1) }
      let(:partial_2_file_path) { build_factory_file(partial_2) }

      let(:partial_1) do
        <<-RUBY
          json.member :id, test_object.id
          json.member :name, test_object.name
          json.member :sub_object, nil
        RUBY
      end

      let(:partial_2) do
        <<-RUBY
          json.object do
            json.member :id, nil
          end
        RUBY
      end

      let(:template) do
        <<-RUBY
          json.object do
            json.member :meta, nil
            json.member :data do
              json.object do
                json.member :id, object.id
                json. member :test_object do
                  json.object do
                    json.member :test, "test"
                    json.partial '#{partial_1_file_path}', test_object: object
                  end
                end

                json.member :test_array do
                  json.object_array(object.test_objects) do |test_object|
                    json.member :name, test_object.name
                    json.member :description, test_object.description
                  end
                end
              end
            end
          end
        RUBY
      end

      let(:context) { { object: test_object } }

      it 'builds json' do
        expect(JSONFactory.build(template, context)).to match_response_schema('object_schema.json')
      end
    end
  end

  describe 'top level array schema' do
    context 'with factory string' do
      let(:template) do
        <<-RUBY
          json.object_array(objects) do |test_object|
            json.member :id, test_object.id
            json.member :name, test_object.name
            json.member :description, test_object.description
          end
        RUBY
      end

      let(:context) { { objects: [test_object_1, test_object_2] } }

      it 'builds json' do
        expect(JSONFactory.build(template, context)).to match_response_schema('top_level_array_schema.json')
      end
    end
  end

  describe 'load partial factory file' do
    after do
      File.unlink(partial_file_path)
    end
    let(:partial) do
      <<-RUBY
        json.member :id, 'id 1'
      RUBY
    end

    let(:partial_file_path) { build_factory_file(partial) }

    let(:template) do
      <<-RUBY
        json.array do
          json.element do
            json.object do
              json.partial '#{partial_file_path}'
            end
          end
          json.element do
            json.object do
              json.member :name, 'name'
              json.partial '#{partial_file_path}'
            end
          end
        end
      RUBY
    end

    it 'evaluates the partial' do
      expect(JSONFactory.build(template)).to eql('[{"id":"id 1"},{"name":"name","id":"id 1"}]')
    end
  end

  describe '#cache' do
    let(:template) do
      <<-RUBY
        json.object do
          json.member :foo do
            json.object do
              json.cache 'test-cache-key' do
                json.member :name, 'name'
              end
            end
          end

          json.member :foo do
            json.object do
              json.member :id, '123'
              json.cache 'test-cache-key' do
                # this will be replaced by the cached value above
              end
            end
          end
        end
      RUBY
    end

    before do
      JSONFactory::Cache.instance.store = ActiveSupport::Cache::MemoryStore.new
      JSONFactory.build(template)
    end

    it 'returns cached json' do
      expect(JSONFactory.build(template)).to eql('{"foo":{"name":"name"},"foo":{"id":"123","name":"name"}}')
    end
  end
end
