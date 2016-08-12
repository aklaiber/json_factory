# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::JSONBuilder do
  let(:test_object_1) { OpenStruct.new(name: 'TestObject1', description: 'Test1') }
  let(:test_object_2) { OpenStruct.new(name: 'TestObject2', description: 'Test2') }

  it 'builds json' do
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

    expect(subject.build).to match_response_schema('object_schema.json')
  end

  describe 'top level array' do
    it 'builds json' do
      subject.schema [test_object_1, test_object_2] do |json, test_object|
        json.name test_object.name
        json.description test_object.description
      end

      expect(subject.build).to match_response_schema('top_level_array_schema.json')
    end
  end

  describe '.load_factory' do
    let(:factory) do
      <<-JBUILDER
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
      JBUILDER
    end

    subject { JSONFactory::JSONBuilder.load_factory(build_factory_file(factory), test_objects: [test_object_1, test_object_2]) }

    it 'builds json' do
      expect(subject.build).to match_response_schema('object_schema.json')
    end
  end

  describe 'partial' do
    let(:partial) do
      <<-JBUILDER
        json.data do |json|
          json.id context.id

          json.test_object do |json|
            json.id 'test object id'
            json.name 'test name'
          end

          json.test_array context.test_objects do |json, test_object|
            json.name test_object.name
            json.description test_object.description
          end
        end
      JBUILDER
    end

    context 'with string' do
      it 'builds json' do
        subject.add_to_comtext(:test_objects, [test_object_1, test_object_2])
        subject.schema do |json|
          json.meta nil
          json.partial! partial, id: 'id 1', test_objects: [test_object_1, test_object_2]
        end

        expect(subject.build).to match_response_schema('object_schema.json')
      end
    end

    context 'with file path' do
      let(:factory) do
        <<-JBUILDER
          json.meta nil
          json.partial! '#{build_factory_file(partial)}', id: 'id 1', test_objects: context.test_objects
        JBUILDER
      end

      subject { JSONFactory::JSONBuilder.new(factory, test_objects: [test_object_1, test_object_2]) }

      it 'builds json' do
        expect(subject.build).to match_response_schema('object_schema.json')
      end
    end
  end
end
