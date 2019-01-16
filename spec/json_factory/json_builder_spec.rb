# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::JSONBuilder do
  describe '#jfactory' do
    subject(:builder) { JSONFactory::JSONBuilder.new(nil) }
    let(:dsl) { JSONFactory::DSL.new(subject) }
    let(:jfactory) { builder.send(:jfactory, dsl) }

    it 'returns a binding' do
      expect(jfactory).to be_a(Binding)
    end

    it 'is an instance of Object' do
      expect(eval('self.class', jfactory, __FILE__, __LINE__)).to eq(Object)
    end

    it 'it resolves constants at the top-level' do
      expect(eval('Module.nesting', jfactory, __FILE__, __LINE__)).to be_empty
    end

    it 'does not contain local variables except for __dsl__ and the execution context' do
      expect(eval('local_variables', jfactory, __FILE__, __LINE__)).to eq([:__dsl__, :execution_context])
    end

    describe '#to_s' do
      it 'returns "jfactory"' do
        expect(eval('self.to_s', jfactory, __FILE__, __LINE__)).to eq('jfactory')
      end
    end

    describe '#inspect' do
      it 'returns "jfactory"' do
        expect(eval('self.inspect', jfactory, __FILE__, __LINE__)).to eq('jfactory')
      end
    end

    describe 'variable scope' do
      let(:a) { builder.send(:jfactory, dsl) }
      let(:b) { builder.send(:jfactory, dsl) }

      it 'returns a new instance every time' do
        expect(a).not_to equal(b)
      end

      it 'does not share local variables between instances' do
        a.local_variable_set(:foo, 1)
        b.local_variable_set(:foo, 2)
        expect(a.local_variable_get(:foo)).to eq(1)
        expect(b.local_variable_get(:foo)).to eq(2)
      end
    end
  end
end
