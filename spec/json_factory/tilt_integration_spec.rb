# frozen_string_literal: true

require 'spec_helper'
require 'tilt'
require 'json_factory/tilt_template'

describe JSONFactory::TiltTemplate do
  let(:template_fixture_file) { File.join(FIXTURES, 'template.jfactory') }

  before(:all) do
    Tilt.register JSONFactory::TiltTemplate, 'jfactory'
  end

  describe "template resolution" do
    it 'should be resolveable with Tilt.templates_for' do
      expect(Tilt.templates_for(template_fixture_file)).to eq([described_class])
    end
   
    it 'should be resolveable with Tilt.new' do
      template = Tilt.new(template_fixture_file)
      expect(template.class).to eq(JSONFactory::TiltTemplate)
    end
  end

  describe "the metadata on class level" do
    it "should set the mime type to application/json" do
      expect(described_class.metadata[:mime_type]).to eq("application/json")
    end
  end

  describe "the metadata on instance level" do
    let(:template) { Tilt.new(template_fixture_file) }

    it "should set the mime type to application/json" do
      expect(template.metadata[:mime_type]).to eq("application/json")
    end
  end

  describe "template rendering through JSONFactory::TiltTemplate" do
    let(:template) { Tilt.new(template_fixture_file) }

    context "without scope" do
      context "without locals" do
        let(:result) { template.render }

        it "should render to the expected result" do
          expect(result).to eq('{"id":"test-id"}')
        end
      end

      context "with locals" do
        let(:template_fixture_file) { File.join(FIXTURES, 'template_with_locals.jfactory') }
        let(:locals) do
          { :hello_variable => "hello",
            :world_variable => "world" }
        end
        let(:result) { template.render(nil, locals) }

        it "should render the expected result" do
          expect(result).to eq('["hello","world"]')
        end
      end
    end
  end

  # describe '#build' do
  #   context 'with a file' do
  #     let(:template_file_path) { build_factory_file(template) }
  #
  #     after do
  #       File.unlink(template_file_path)
  #     end
  #
  #     subject { JSONFactory::Builder.new(template_file_path) }
  #
  #     it 'builds json' do
  #       expect(subject.build).to eql('{"id":"test-id"}')
  #     end
  #   end
  #
  #   context 'with a string' do
  #     subject { JSONFactory::Builder.new(template) }
  #
  #     it 'builds json' do
  #       expect(subject.build).to eql('{"id":"test-id"}')
  #     end
  #   end
  # end
end
