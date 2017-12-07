# frozen_string_literal: true

require 'jbuilder'
require 'benchmark'
require 'forgery'

require_relative '../lib/json_factory'

objects = []
sub_array = []

10.times do
  sub_array << OpenStruct.new(
    id: rand(1_000_000_000),
    name: 'TestObject1',
    description: 'Test1',
    test_array: sub_array
  )
end

1000.times do |i|
  objects << OpenStruct.new(
    id: i,
    name: 'TestObject1',
    description: 'Test1',
    test_array: sub_array
  )
end

# CURRENT RUNTIME WITH 1000 and 10 = 0.133410
Benchmark.bmbm(15) do |x|
  x.report(:json_factory) do
    builder = JSONFactory::JSONBuilder.load_factory_file('fixtures/test.jfactory')
    builder.build(JSONFactory::Context.new(objects: objects))
  end
end
