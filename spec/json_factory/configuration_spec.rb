# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::Configuration do
  describe '#include_helper' do
    let(:helper) do
      Module.new do
        def test
          'test value'
        end
      end
    end

    it 'includes module' do
      JSONFactory.configure do |config|
        config.include_helper(helper)
      end

      expect(JSONFactory.build('json.value test')).to eq('"test value"')
    end
  end

  describe '#extend_dsl' do
    let(:extension) do
      Module.new do
        def test_it
          'test value'
        end
      end
    end

    it 'includes module' do
      expect(JSONFactory::DSL).to receive(:include).with(extension)

      JSONFactory.configure do |config|
        config.extend_dsl(extension)
      end
    end
  end
end
