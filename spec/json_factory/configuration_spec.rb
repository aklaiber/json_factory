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

    before do
      JSONFactory.configure do |config|
        config.include_helper(helper)
      end
    end

    it 'generates a single value with helper return value' do
      expect(JSONFactory.build('json.value test')).to eq('"test value"')
    end
  end
end
