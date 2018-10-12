# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::DSL do
  let(:context) { {} }
  let(:result) { JSONFactory.build(template, context) }

  before(:context) do
    JSONFactory::Cache.instance.store = ActiveSupport::Cache::MemoryStore.new
  end

  describe '#value' do
    context 'with a numeric argument' do
      let(:template) { 'value 1' }
      it 'generates a single value' do
        expect(result).to eq('1')
      end
    end

    context 'with nil argument' do
      let(:template) { 'value nil' }
      it 'generates a null value' do
        expect(result).to eq('null')
      end
    end

    context 'with block argument' do
      let(:template) { 'value 1 {}' }
      it 'uses the given value' do
        silence_warnings do
          expect(result).to eq('1')
        end
      end
      it 'warns about unused block' do
        expect { result }.to output(/given block not used/).to_stderr
      end
    end

    describe 'argument errors' do
      context 'without arguments' do
        let(:template) { 'value' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 0, expected 1)'
        end
      end

      context 'with too many arguments' do
        let(:template) { 'value 1, 2' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 2, expected 1)'
        end
      end
    end

    describe 'state errors' do
      context 'value within object' do
        let(:template) { 'object { value 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add value as a value'
        end
      end

      context 'value within array' do
        let(:template) { 'array { value 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add value as a value'
        end
      end
    end
  end

  describe '#array' do
    context 'empty array' do
      let(:template) { 'array' }
      it 'generates an empty array literal' do
        expect(result).to eq('[]')
      end
    end

    context 'empty array with block' do
      let(:template) { 'array {}' }
      it 'generates an empty array literal' do
        expect(result).to eq('[]')
      end
    end

    describe 'argument errors' do
      context 'with argument' do
        let(:template) { 'array 1' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 1, expected 0)'
        end
      end
    end

    describe 'state errors' do
      context 'array within array' do
        let(:template) { 'array { array }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add array as a value'
        end
      end

      context 'array within object' do
        let(:template) { 'object { array }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add array as a value'
        end
      end
    end
  end

  describe '#element' do
    context 'array with single element' do
      let(:template) { 'array { element 1 }' }
      it 'generates an array literal containing the element' do
        expect(result).to eq('[1]')
      end
    end

    context 'array with two elements' do
      let(:template) { 'array { element 1 ; element 2 }' }
      it 'generates an array literal containing the elements separated by comma' do
        expect(result).to eq('[1,2]')
      end
    end

    context 'with block value' do
      let(:template) { 'array { element { value 1 } }' }
      it 'generates an array literal containing the element' do
        expect(result).to eq('[1]')
      end
    end

    context 'with empty block' do
      let(:template) { 'array { element {} }' }
      it 'raises an error' do
        expect { result }.to raise_error JSONFactory::EmptyValueError
      end
    end

    context 'with positional and block argument' do
      let(:template) { 'array { element 1 { value 2 } }' }
      it 'evaluates the block' do
        silence_warnings do
          expect(result).to eq('[2]')
        end
      end
      it 'warns about unused value' do
        expect { result }.to output(/block supersedes value argument/).to_stderr
      end
    end

    describe 'argument errors' do
      context 'without arguments' do
        let(:template) { 'array { element }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 0, expected 1)'
        end
      end

      context 'with too many arguments' do
        let(:template) { 'array { element 1, 2 }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 2, expected 1)'
        end
      end
    end

    describe 'state errors' do
      context 'top level element' do
        let(:template) { 'element 1' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add an element within an array'
        end
      end

      context 'element within object' do
        let(:template) { 'object { element 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add an element within an array'
        end
      end
    end
  end

  describe '#object' do
    context 'empty object' do
      let(:template) { 'object' }
      it 'generates an empty object literal' do
        expect(result).to eq('{}')
      end
    end

    context 'empty object with block' do
      let(:template) { 'object {}' }
      it 'generates an empty object literal' do
        expect(result).to eq('{}')
      end
    end

    describe 'argument errors' do
      context 'with argument' do
        let(:template) { 'object 1' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 1, expected 0)'
        end
      end
    end

    describe 'state errors' do
      context 'object within object' do
        let(:template) { 'object { object }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add object as a value'
        end
      end

      context 'object within array' do
        let(:template) { 'array { object }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add object as a value'
        end
      end
    end
  end

  describe '#member' do
    context 'object with single member' do
      let(:template) { 'object { member :foo, 1 }' }
      it 'generates an object literal containing the member' do
        expect(result).to eq('{"foo":1}')
      end
    end

    context 'object with two members' do
      let(:template) { 'object { member :foo, 1 ; member :bar, 2 }' }
      it 'generates an object literal containing the members separated by comma' do
        expect(result).to eq('{"foo":1,"bar":2}')
      end
    end

    context 'with block value' do
      let(:template) { 'object { member :foo { value 1 } }' }
      it 'generates an array literal containing the member' do
        expect(result).to eq('{"foo":1}')
      end
    end

    context 'with empty block' do
      let(:template) { 'object { member :foo {} }' }
      it 'raises an error' do
        expect { result }.to raise_error JSONFactory::EmptyValueError
      end
    end

    context 'with positional and block argument' do
      let(:template) { 'object { member :foo, 1 { value 2 } }' }
      it 'evaluates the block' do
        silence_warnings do
          expect(result).to eq('{"foo":2}')
        end
      end
      it 'warns about unused value' do
        expect { result }.to output(/block supersedes value argument/).to_stderr
      end
    end

    describe 'argument errors' do
      context 'without value argument' do
        let(:template) { 'object { member :foo }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 1, expected 2)'
        end
      end

      context 'with too many arguments' do
        let(:template) { 'object { member :foo, 1, 2 }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 3, expected 2)'
        end
      end
    end

    describe 'state errors' do
      context 'top level member' do
        let(:template) { 'member :foo, 1' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add a member within an object'
        end
      end

      context 'member within array' do
        let(:template) { 'array { member :foo, 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add a member within an object'
        end
      end
    end
  end

  describe '#cache' do
    let(:template) do
      <<~RUBY
        object do
          member :foo do
            object do
              cache 'test-cache-key' do
                member :name, 'name'
              end
            end
          end

          member :foo do
            object do
              member :id, '123'
              cache 'test-cache-key' do
                # this will be replaced by the cached value above
              end
            end
          end
        end
      RUBY
    end

    it 'generates an object literal' do
      expect(result).to eql('{"foo":{"name":"name"},"foo":{"id":"123","name":"name"}}')
    end

    # Not sure if this should be possible
    context 'when key is nil' do
      let(:template) do
        <<~RUBY
        object do
          member :foo do
            object do
              cache nil do
                member :name, 'name'
              end
            end
          end

          member :foo do
            object do
              member :id, '123'
              cache nil do
                # this will be replaced by the cached value above
              end
            end
          end
        end
        RUBY
      end

      it 'generates an object literal' do
        expect(result).to eql('{"foo":{"name":"name"},"foo":{"id":"123","name":"name"}}')
      end
    end
  end

  describe '#partial' do
    after do
      File.unlink(partial_file_path)
    end

    let(:partial_file_path) { build_factory_file(partial) }

    let(:partial) do
      <<-RUBY
        member :id, 'id 1'
      RUBY
    end

    let(:template) do
      <<-RUBY
        array do
          element do
            object do
              partial '#{partial_file_path}'
            end
          end
          element do
            object do
              member :name, 'name'
              partial '#{partial_file_path}'
            end
          end
        end
      RUBY
    end

    it 'evaluates the partial' do
      expect(result).to eql('[{"id":"id 1"},{"name":"name","id":"id 1"}]')
    end
  end

  describe '#object_if' do
    context 'when condition is true' do
      let(:template) do
        <<~RUBY
          object do 
            member :foo do 
              object_if(true) do 
                member :bar, 1 
              end 
            end 
          end
        RUBY
      end

      it 'generates an object literal' do
        expect(result).to eq('{"foo":{"bar":1}}')
      end
    end

    context 'when condition is false' do
      let(:template) do
        <<~RUBY
          object do 
            member :foo do 
              object_if(false) do 
                member :bar, 1 
              end 
            end 
          end
        RUBY
      end

      it 'generates an empty object literal' do
        expect(result).to eq('{"foo":null}')
      end
    end
  end

  describe '#object_array' do
    let(:template) do
      <<~RUBY
        object_array(objects) do |test_object|
          member :id, test_object.id
        end
      RUBY
    end

    let(:context) do
      { objects: [OpenStruct.new(id: 1), OpenStruct.new(id: 2)] }
    end

    it 'generates an array literal' do
      expect(result).to eq('[{"id":1},{"id":2}]')
    end
  end

  describe 'all methods' do
    after { File.unlink(partial_1_file_path, partial_2_file_path) }

    let(:test_object) { OpenStruct.new(id: '1', test_objects: [OpenStruct.new(id: '01'), OpenStruct.new(id: '02')]) }

    let(:partial_1_file_path) { build_factory_file(partial_1) }
    let(:partial_2_file_path) { build_factory_file(partial_2) }

    let(:partial_1) do
      <<-RUBY
        member :id, test_object.id
      RUBY
    end

    let(:partial_2) do
      <<-RUBY
        object do
          member :id, nil
        end
      RUBY
    end

    let(:template) do
      <<-RUBY
        object do
          member :data do
            object do
              member :id, object.id
               member :test_object do
                object do
                  member :test, "test"
                  partial '#{partial_1_file_path}', test_object: object
                end
              end

              member :test_array do
                object_array(object.test_objects) do |test_object|
                  member :id, test_object.id
                end
              end
            end
          end
        end
      RUBY
    end

    let(:context) do
      { object: test_object }
    end

    it 'builds json' do
      expect(result).to eql('{"data":{"id":"1","test_object":{"test":"test","id":"1"},"test_array":[{"id":"01"},{"id":"02"}]}}')
    end
  end

  describe 'extend dsl' do
    let(:extension) do
      Module.new do
        def test_it
          value('test value')
        end
      end
    end

    before do
      JSONFactory.configure do |config|
        config.extend_dsl(extension)
      end
    end

    let(:template) { 'test_it' }

    it 'generates a single value' do
      expect(JSONFactory.build('test_it')).to eq('"test value"')
    end
  end

  describe 'add helper' do
    let(:helper) do
      Module.new do
        def test
          'test value'
        end
      end
    end

    before do
      JSONFactory.configure do |config|
        config.include_helper(helper)
      end
    end

    it 'generates a single value with helper return value' do
      expect(JSONFactory.build('value test')).to eq('"test value"')
    end
  end
end
