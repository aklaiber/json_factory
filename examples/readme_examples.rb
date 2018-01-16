# frozen_string_literal: true

require_relative '../lib/json_factory'

# test data
test_object1 = OpenStruct.new(id: '001', name: 'TestObject2')
test_object2 = OpenStruct.new(id: '002', name: 'TestObject3')
test_object = OpenStruct.new(id: '1', name: 'TestObject1', description: 'Test2', test_objects: [test_object1, test_object2])

factory = <<-RUBY
  object! do
    object!(:data) do
      member!(:id, object.id)
      member!(:name, object.name)
      member!(:test_array) do
        array!(object.test_objects) do |test_object|
          member!(:id, test_object.id)
          member!(:name, test_object.name)
        end
      end
    end
  end
RUBY

# create context object
context = JSONFactory::Context.new(object: test_object)

puts JSONFactory::JSONBuilder.new(factory, context).build

factory = <<-RUBY
  array! objects do |test_object|
    member!(:id, test_object.id)
    member!(:name, test_object.name)
  end
RUBY
# create context object
context = JSONFactory::Context.new(objects: [test_object1, test_object2])

puts JSONFactory::JSONBuilder.new(factory, context).build
