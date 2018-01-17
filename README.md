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

| DSL Method | Description                                                         | 
| ---------- |:------------------------------------------------------------------- |  
| value      | Generates a JSON value.                                             |   
| object     | Generates a JSON object structure.                                  |   
| member     | Adds a key-value pair to a JSON object.                             |
| array      | Generates a JSON array structure.                                   | 
| element    | Adds a value to a JSON array.                                        | 
| partial    | Loads the given partial and evaluates it using the local variables. |
| cache      | Caches the given content under the specified key.                   |

##### Top level object  JSON structure

```ruby
factory = <<-RUBY
  json.object do
    json.member :data do
      json.object do
        json.member :id, object.id
        json.member :name, object.name
        json.member :test_array do
          json.object_array(object.test_objects) do |test_object|
            json.member :id, test_object.id)
            json.member :name, test_object.name
          end
        end
      end
    end 
  end
RUBY

# test data 
test_object_1 = OpenStruct.new(id: '001', name: 'TestObject2')
test_object_2 = OpenStruct.new(id: '002', name: 'TestObject3')
test_object = OpenStruct.new(id: '1', name: 'TestObject1', test_objects: [test_object_1, test_object_2])

puts JSONFactory.build(factory, object: test_object)
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
  json.object_array objects  do |test_object|
    json.member :id, test_object.id
    json.member :name, test_object.name
  end
RUBY

# test data 
test_object_1 = OpenStruct.new(id: '001', name: 'TestObject2')
test_object_2 = OpenStruct.new(id: '002', name: 'TestObject3')

puts JSONFactory.build(factory, objects: [test_object_1, test_object_2])
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
json.member :id, test_object.id
json.member :name, test_object.name
``` 

```ruby
# test data
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

puts JSONFactory.build('tmp/test.jfactory', object: test_object).build # => { "id": 1, name: "TestObject1" }
```        

##### Load partials 

```ruby
# tmp/_test_partial.jfactory
json.member :id, test_object.id
json.member :name, test_object.name
```  

```ruby
# tmp/test.jfactory
json.object do
  json.partial 'tmp/test_partial', test_object: object
end
``` 

```ruby
# test data
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

puts JSONFactory.build('tmp/test.jfactory', object: test_object).build # => { "id": 1, name: "TestObject1" }
```  

##### Use cache stores

```ruby
factory = <<-RUBY
  json.object do
    json.member :data do
      json.object do
        json.cache 'test-cache-key' do
          json.member :id, object.id
          json.member :name, object.name
        end
      end
    end
  end
RUBY

# test data 
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

JSONFactory::Cache.instance.store = = ActiveSupport::Cache::MemoryStore.new

puts JSONFactory.build(factory, object: test_object) # => { "data": { "id": "1", "name": "TestObject1" } }
```

## Development

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aklaiber/json_factory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

