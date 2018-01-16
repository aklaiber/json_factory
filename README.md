[![Build Status](https://travis-ci.org/aklaiber/json_factory.svg?branch=master)](https://travis-ci.org/aklaiber/json_factory)

# JsonFactory

JsonFactory is a Easy DSL to create JSON structures with the development focus on performance. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json_factory'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_factory

## Usage

| DSL Method | Description                      | 
| ---------- |:-------------------------------- |  
| object!    | Create a json object             |   
| array!     | Create a json array              | 
| member!    | Create key value pair            |
| null!      | Set object to "null"             |   
| partial!   | Load sub jfactory file           |
| cache!     | Read and write from cache stores |

##### Top level object  JSON structure

```ruby
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

# test data 
test_object_1 = OpenStruct.new(id: '001', name: 'TestObject2')
test_object_2 = OpenStruct.new(id: '002', name: 'TestObject3')
test_object = OpenStruct.new(id: '1', name: 'TestObject1', test_objects: [test_object_1, test_object_2])

# create context object
context = JSONFactory::Context.new(object: test_object)

puts JSONFactory::JSONBuilder.new(factory, context).build
```

```json
{
  "data": {
    "id": "1",
    "name": "TestObject1",
    "test_array": [
      { "id": "001", "name": "TestObject2" },
      { "id": "002", "name": "TestObject3" }
    ]
  }
}
```

##### Top level array JSON structure

```ruby
factory = <<-RUBY
  array! objects do |test_object|
    member!(:id, test_object.id)
    member!(:name, test_object.name)
  end
RUBY

# test data 
test_object_1 = OpenStruct.new(id: '001', name: 'TestObject2')
test_object_2 = OpenStruct.new(id: '002', name: 'TestObject3')

# create context object
context = JSONFactory::Context.new(objects: [test_object_1, test_object_2])

puts JSONFactory::JSONBuilder.new(factory, context).build
```

```json
[
  { "id": "001", "name": "TestObject2" },
  { "id": "002", "name": "TestObject3" }
]
```

##### Load jfactory files

```ruby
# tmp/test.jfactory
member!(:id, test_object.id)
member!(:name, test_object.name)
``` 

```ruby
# test data
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

# create context object
context = JSONFactory::Context.new(object: test_object)

puts JSONFactory::JSONBuilder.load_factory_file('tmp/test.jfactory', context).build # => { "id": 1, name: "TestObject1" }
```        

##### Load partials 

```ruby
# tmp/_test_partial.jfactory
member!(:id, test_object.id)
member!(:name, test_object.name)
```  

```ruby
# tmp/test.jfactory
object! do
  partial!('tmp/test_partial', test_object: object)
end
``` 

```ruby
# test data
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

# create context object
context = JSONFactory::Context.new(object: test_object)

puts JSONFactory::JSONBuilder.load_factory_file('tmp/test.jfactory', context).build # => { "id": 1, name: "TestObject1" }
```  

##### Use cache stores

```ruby
factory = <<-RUBY
  object! do
    object!(:data) do
      cache! 'test-cache-key' do
        member!(:id, object.id)
        member!(:name, object.name)
      end
    end
  end
RUBY

# test data 
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

# create context object
context = JSONFactory::Context.new(object: test_object)

builder = JSONFactory::JSONBuilder.new(factory, context)
builder.cache.store = ActiveSupport::Cache::MemoryStore.new
puts builder.build # => { "data": { "id": "1", "name": "TestObject1" } }
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aklaiber/json_factory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

