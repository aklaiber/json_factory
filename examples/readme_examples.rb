require_relative '../lib/json_factory'

# test data
test_object_1 = OpenStruct.new(id: '001', name: 'TestObject2')
test_object_2 = OpenStruct.new(id: '002', name: 'TestObject3')
test_object = OpenStruct.new(id: '1', name: 'TestObject1', description: 'Test2', test_objects: [test_object_1, test_object_2])

factory = <<-RUBY
  json.object! do |json|
    json.object!(:data) do |json|
      json.member!(:id, object.id)
      json.member!(:name, object.name)

      json.array!(object.test_objects, :test_array) do |json, test_object|
        json.member!(:id, test_object.id)
        json.member!(:name, test_object.name)
      end
    end
  end
RUBY

# create context object
context = JSONFactory::Context.new(object: test_object)

puts JSONFactory::JSONBuilder.new(factory, context).build



factory = <<-RUBY
  json.array! objects do |json, test_object|
    json.member!(:id, test_object.id)
    json.member!(:name, test_object.name)
  end
RUBY
# create context object
context = JSONFactory::Context.new(objects: [test_object_1, test_object_2])

puts JSONFactory::JSONBuilder.new(factory, context).build
