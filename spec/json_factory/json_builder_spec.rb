# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::JSONBuilder do
  let(:test_object_1) { OpenStruct.new(id: '001', name: 'TestObject1', description: 'Test1') }
  let(:test_object_2) { OpenStruct.new(id: '002', name: 'TestObject2', description: 'Test2') }

  describe 'object schema' do
    context 'with schema' do
      before do
        subject.schema do |json|
          json.meta nil

          json.data do |json|
            json.id 'id 1'

            json.test_object do |json|
              json.id 'test object id'
              json.name 'test name'
            end

            json.test_array [test_object_1, test_object_2] do |json, test_object|
              json.name test_object.name
              json.description test_object.description
            end
          end
        end
      end

      it 'builds json' do
        expect(subject.build).to match_response_schema('object_schema.json')
      end
    end

    context 'with factory' do
      let(:factory) do
        <<-RUBY
          json.meta nil
  
          json.data do |json|
            json.id 'id 1'
  
            json.test_object do |json|
              json.id 'test object id'
              json.name 'test name'
            end
  
            json.test_array context.test_objects do |json, test_object|
              json.name test_object.name
              json.description test_object.description
            end
          end
        RUBY
      end

      subject { JSONFactory::JSONBuilder.new(factory, test_objects: [test_object_1, test_object_2]) }

      it 'builds json' do
        expect(subject.build).to match_response_schema('object_schema.json')
      end
    end

    xcontext 'with invalid factory' do
      let(:factory) do
        <<-RUBY
        RUBY
      end

      subject { JSONFactory::JSONBuilder.new(factory) }

      it 'builds json' do
      end
    end
  end

  describe 'top level array schema' do
    let(:data) { [test_object_1, test_object_2] }

    context 'with schema' do
      before do
        subject.schema data do |json, test_object|
          json.id test_object.id
          json.name test_object.name
          json.description test_object.description
        end
      end

      it 'builds json' do
        expect(subject.build).to match_response_schema('top_level_array_schema.json')
      end
    end

    context 'with factory' do
      let(:factory) do
        <<-RUBY
          json.schema context.data do |json, test_object|
            json.id test_object.id
            json.name test_object.name
            json.description test_object.description
          end
        RUBY
      end

      subject { JSONFactory::JSONBuilder.new(factory, data) }

      it 'builds json' do
        expect(subject.build).to match_response_schema('top_level_array_schema.json')
      end
    end
  end

  describe 'partial' do
    let(:partial) do
      <<-RUBY
        json.data do |json|
          json.id context.id
        end
      RUBY
    end

    context 'with string' do
      before do
        subject.schema do |json|
          json.partial! partial, id: 'id 1'
        end
      end

      it 'builds json' do
        expect(subject.build).to eql('{"data":{"id":"id 1"}}')
      end
    end

    context 'with factory file path' do
      let(:data) { [test_object_1, test_object_2] }
      let(:partial_file_path) { build_factory_file(partial) }

      let(:partial) do
        <<-RUBY
          json.id context.test_object.id
        RUBY
      end

      let(:factory) do
        <<-RUBY
          json.schema context.data do |json, test_object|
            json.partial! '#{partial_file_path}', test_object: test_object
          end
        RUBY
      end

      subject { JSONFactory::JSONBuilder.new(factory, [test_object_1, test_object_2]) }

      it 'builds json' do
        expect(subject.build).to eql('[{"id":"001"},{"id":"002"}]')
      end
    end
  end

  describe '.load_factory' do
    let(:factory) do
      <<-RUBY
        json.id 'test-id'
      RUBY
    end

    subject { JSONFactory::JSONBuilder.load_factory_file(build_factory_file(factory), test_objects: [test_object_1, test_object_2]) }

    it 'builds json' do
      expect(subject.build).to eql('{"id":"test-id"}')
    end
  end
end
