# frozen_string_literal: true

require 'spec_helper'

describe JSONFactory::Builder do
  let(:template) do
    <<-RUBY
        json.object do
          json.member(:id, 'test-id')
        end
    RUBY
  end

  describe '#build' do
    context 'with a file' do
      let(:template_file_path) { build_factory_file(template) }

      after do
        File.unlink(template_file_path)
      end

      subject { JSONFactory::Builder.new(template_file_path) }

      it 'builds json' do
        expect(subject.build).to eql('{"id":"test-id"}')
      end
    end

    context 'with a string' do
      subject { JSONFactory::Builder.new(template) }

      it 'builds json' do
        expect(subject.build).to eql('{"id":"test-id"}')
      end
    end
  end
end
