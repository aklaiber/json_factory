# frozen_string_literal: true

shared_examples 'a cache store proxy' do
  let(:prefix) { 'json_factory' }
  let(:key) { 'cache-test-key' }

  after do
    store.clear
  end

  describe '#write' do
    before do
      subject.write(key, 'test')
    end

    it { expect(store.read("#{prefix}:#{key}")).to eql('test') }
  end

  describe '#read' do
    before do
      store.write("#{prefix}:#{key}", 'test')
    end

    it { expect(subject.read(key)).to eql('test') }
  end

  describe '#delete' do
    before do
      store.write("#{prefix}:#{key}", 'test')
    end

    it { expect { subject.delete(key) }.to change { store.read("#{prefix}:#{key}") }.from('test').to(nil) }
  end
end
