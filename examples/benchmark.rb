# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'jbuilder'
require 'benchmark'
require 'forgery'

require 'json_factory'

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
Benchmark.bmbm(10) do |x|
  x.report(:json_factory) do
    JSONFactory.build_template('fixtures/test.jfactory', objects: objects)
  end
end
