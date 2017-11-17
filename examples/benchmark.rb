# frozen_string_literal: true

require 'benchmark'
require 'jbuilder'
require 'multi_json'
require 'json'
require 'colorize'
require 'forgery'

require_relative '../lib/json_factory'

Oj.default_options = { mode: :strict }

MultiJson.use :oj

objects = []
sub_array = []

50.times do
  sub_array << Forgery(:lorem_ipsum).words(rand(10))
end

10_000.times do |i|
  objects << OpenStruct.new(
    id: i,
    name: 'TestObject1',
    description: 'Test1',
    test_array: sub_array
  )
end

oj_json = ''
json_factory_json = ''
jbuilder_json = ''

Benchmark.bmbm(15) do |x|
  x.report(:oj) do
    oj_json = Oj.dump(
      objects.map do |entry|
        {
          'id' => entry.id,
          'name' => entry.name,
          'description' => entry.description,
          'test_array' => entry.test_array
        }
      end
    )
  end
  x.report(:json_factory) do
    builder = JSONFactory::JSONBuilder.new
    builder.schema objects do |json, test_object|
      json.id test_object.id
      json.name test_object.name
      json.description test_object.description
      json.test_array test_object.test_array
    end
    json_factory_json = builder.build
  end
  x.report(:jbuilder) do
    builder = Jbuilder.new do |json|
      json.array! objects do |test_object|
        json.id test_object.id
        json.name test_object.name
        json.description test_object.description
        json.test_array test_object.test_array
      end
    end
    jbuilder_json = builder.target!
  end
end

puts

if oj_json == json_factory_json && oj_json == jbuilder_json && json_factory_json == jbuilder_json
  puts 'Generated json are equal'.colorize(:light_green)
else
  puts 'Generated json are not equal'.colorize(:light_red)
end
