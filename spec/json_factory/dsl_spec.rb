# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::DSL do
  let(:result) { JSONFactory.build(template) }

  describe '#value' do
    describe 'with a numeric argument' do
      let(:template) { 'json.value 1' }
      it 'generates a single value' do
        expect(result).to eq('1')
      end
    end

    describe 'with nil argument' do
      let(:template) { 'json.value nil' }
      it 'generates a null value' do
        expect(result).to eq('null')
      end
    end

    describe 'with block argument' do
      let(:template) { 'json.value 1 {}' }
      it 'uses the given value' do
        silence_warnings do
          expect(result).to eq('1')
        end
      end
      it 'warns about unused block' do
        expect { result }.to output(/given block not used/).to_stderr
      end
    end

    context 'argument errors' do
      describe 'without arguments' do
        let(:template) { 'json.value' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 0, expected 1)'
        end
      end

      describe 'with too many arguments' do
        let(:template) { 'json.value 1, 2' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 2, expected 1)'
        end
      end
    end

    context 'state errors' do
      describe 'value within object' do
        let(:template) { 'json.object { json.value 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add value as a value'
        end
      end

      describe 'value within array' do
        let(:template) { 'json.array { json.value 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add value as a value'
        end
      end
    end
  end

  describe '#array' do
    describe 'empty array' do
      let(:template) { 'json.array' }
      it 'generates an empty array literal' do
        expect(result).to eq('[]')
      end
    end

    describe 'empty array with block' do
      let(:template) { 'json.array {}' }
      it 'generates an empty array literal' do
        expect(result).to eq('[]')
      end
    end

    context 'argument errors' do
      describe 'with argument' do
        let(:template) { 'json.array 1' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 1, expected 0)'
        end
      end
    end

    context 'state errors' do
      describe 'array within array' do
        let(:template) { 'json.array { json.array }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add array as a value'
        end
      end

      describe 'array within object' do
        let(:template) { 'json.object { json.array }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add array as a value'
        end
      end
    end
  end

  describe '#element' do
    describe 'array with single element' do
      let(:template) { 'json.array { json.element 1 }' }
      it 'generates an array literal containing the element' do
        expect(result).to eq('[1]')
      end
    end

    describe 'array with two elements' do
      let(:template) { 'json.array { json.element 1 ; json.element 2 }' }
      it 'generates an array literal containing the elements separated by comma' do
        expect(result).to eq('[1,2]')
      end
    end

    describe 'with block value' do
      let(:template) { 'json.array { json.element { json.value 1 } }' }
      it 'generates an array literal containing the element' do
        expect(result).to eq('[1]')
      end
    end

    describe 'with empty block' do
      let(:template) { 'json.array { json.element {} }' }
      it 'raises an error' do
        expect { result }.to raise_error JSONFactory::EmptyValueError
      end
    end

    describe 'with positional and block argument' do
      let(:template) { 'json.array { json.element 1 { json.value 2 } }' }
      it 'evaluates the block' do
        silence_warnings do
          expect(result).to eq('[2]')
        end
      end
      it 'warns about unused value' do
        expect { result }.to output(/block supersedes value argument/).to_stderr
      end
    end

    context 'argument errors' do
      describe 'without arguments' do
        let(:template) { 'json.array { json.element }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 0, expected 1)'
        end
      end

      describe 'with too many arguments' do
        let(:template) { 'json.array { json.element 1, 2 }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 2, expected 1)'
        end
      end
    end

    context 'state errors' do
      describe 'top level element' do
        let(:template) { 'json.element 1' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add an element within an array'
        end
      end

      describe 'element within object' do
        let(:template) { 'json.object { json.element 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add an element within an array'
        end
      end
    end
  end

  describe '#object' do
    describe 'empty object' do
      let(:template) { 'json.object' }
      it 'generates an empty object literal' do
        expect(result).to eq('{}')
      end
    end

    describe 'empty object with block' do
      let(:template) { 'json.object {}' }
      it 'generates an empty object literal' do
        expect(result).to eq('{}')
      end
    end

    context 'argument errors' do
      describe 'with argument' do
        let(:template) { 'json.object 1' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 1, expected 0)'
        end
      end
    end

    context 'state errors' do
      describe 'object within object' do
        let(:template) { 'json.object { json.object }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add object as a value'
        end
      end

      describe 'object within array' do
        let(:template) { 'json.array { json.object }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add object as a value'
        end
      end
    end
  end

  describe '#member' do
    describe 'object with single member' do
      let(:template) { 'json.object { json.member :foo, 1 }' }
      it 'generates an object literal containing the member' do
        expect(result).to eq('{"foo":1}')
      end
    end

    describe 'object with two members' do
      let(:template) { 'json.object { json.member :foo, 1 ; json.member :bar, 2 }' }
      it 'generates an object literal containing the members separated by comma' do
        expect(result).to eq('{"foo":1,"bar":2}')
      end
    end

    describe 'with block value' do
      let(:template) { 'json.object { json.member :foo { json.value 1 } }' }
      it 'generates an array literal containing the member' do
        expect(result).to eq('{"foo":1}')
      end
    end

    describe 'with empty block' do
      let(:template) { 'json.object { json.member :foo {} }' }
      it 'raises an error' do
        expect { result }.to raise_error JSONFactory::EmptyValueError
      end
    end

    describe 'with positional and block argument' do
      let(:template) { 'json.object { json.member :foo, 1 { json.value 2 } }' }
      it 'evaluates the block' do
        silence_warnings do
          expect(result).to eq('{"foo":2}')
        end
      end
      it 'warns about unused value' do
        expect { result }.to output(/block supersedes value argument/).to_stderr
      end
    end

    context 'argument errors' do
      describe 'without value argument' do
        let(:template) { 'json.object { json.member :foo }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 1, expected 2)'
        end
      end

      describe 'with too many arguments' do
        let(:template) { 'json.object { json.member :foo, 1, 2 }' }
        it 'raises an error' do
          expect { result }.to raise_error ArgumentError, 'wrong number of arguments (given 3, expected 2)'
        end
      end
    end

    context 'state errors' do
      describe 'top level member' do
        let(:template) { 'json.member :foo, 1' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add a member within an object'
        end
      end

      describe 'member within array' do
        let(:template) { 'json.array { json.member :foo, 1 }' }
        it 'raises an error' do
          expect { result }.to raise_error JSONFactory::TypeNotAllowedError, 'Can only add a member within an object'
        end
      end
    end
  end

  describe '#cache' do
    pending
  end

  describe '#partial' do
    pending
  end
end
