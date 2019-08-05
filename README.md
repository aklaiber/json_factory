[![Build Status](https://travis-ci.org/aklaiber/json_factory.svg?branch=master)](https://travis-ci.org/aklaiber/json_factory)

# JsonFactory

JsonFactory is a Easy DSL to create JSON with focus on performance and flexibility. 

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

| DSL Method                           | Description                                                         | 
| ------------------------------------ |:------------------------------------------------------------------- |  
| [value](#value-method)               | Generates a JSON value.                                             |   
| [object](#object-method)             | Generates a JSON object.                                            |   
| [member](#member-method)             | Adds a key-value pair to a JSON object.                             |
| [array](#array-method)               | Generates a JSON array.                                             | 
| [object_array](#object_array-method) | Generates a JSON array.                                             |
| [element](#element-method)           | Adds a value to a JSON array.                                       | 
| [partial](#partial-method)           | Loads the given partial and evaluates it using the local variables. |
| [cache](#cache-method)               | Caches the given content under the specified key.                   |
| [object_if](#object_if-method)       | Generates a JSON object if condition is true.                       |

##### value method 

```ruby
factory = <<-RUBY
  value nil
RUBY

puts JSONFactory.build(factory) # => null
```

##### object method 

```ruby
factory = <<-RUBY
  object do
    member :data do
      object do
        member :id, object.id
      end
    end 
  end
RUBY

# test data 
test_object = OpenStruct.new(id: 1)

puts JSONFactory.build(factory, object: test_object) # => {"data":{"id":1}}
```

##### member method 

```ruby
factory = <<-RUBY
  object do 
    member :foo, 'bar' 
  end
RUBY

puts JSONFactory.build(factory) # => {"foo":"bar"}
```

##### array method

```ruby
factory = <<-RUBY
  array do
    objects.each do |test_object|   
      element :id, test_object.id
    end
  end
RUBY

# test data 
test_object_1 = OpenStruct.new(id: 1)
test_object_2 = OpenStruct.new(id: 2)

puts JSONFactory.build(factory, objects: [test_object_1, test_object_2]) # => [{"id": 1},{"id":2}]
```

##### object_array method

```ruby
factory = <<-RUBY
  object_array objects do |test_object|
    member :id, test_object.id
  end
RUBY

# test data 
test_object_1 = OpenStruct.new(id: 1)
test_object_2 = OpenStruct.new(id: 2)

puts JSONFactory.build(factory, objects: [test_object_1, test_object_2]) # => [{"id":1},{"id":2}]
```

##### element method

```ruby
factory = <<-RUBY
  array do
    objects.each do |test_object|   
      element :id, test_object.id
    end
  end
RUBY

# test data 
test_object_1 = OpenStruct.new(id: 1)
test_object_2 = OpenStruct.new(id: 2)

puts JSONFactory.build(factory, objects: [test_object_1, test_object_2]) # => [{"id": 1},{"id":2}]
```

##### partial method

```ruby
# tmp/_test_partial.jfactory
member :id, test_object.id
member :name, test_object.name
```  

```ruby
# tmp/test.jfactory
object do
  partial 'tmp/test_partial', test_object: object
end
``` 

```ruby
# test data
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

puts JSONFactory.build('tmp/test.jfactory', object: test_object).build # => { "id": 1, name: "TestObject1" }
```  

##### cache method

```ruby
factory = <<-RUBY
  object do
    member :data do
      object do
        cache 'test-cache-key' do
          member :id, object.id
          member :name, object.name
        end
      end
    end
  end
RUBY

# test data 
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

# set cache store
JSONFactory::Cache.instance.store = ActiveSupport::Cache::MemoryStore.new

puts JSONFactory.build(factory, object: test_object) # => { "data": { "id": "1", "name": "TestObject1" } }
```

##### object_if method

```ruby
factory = <<-RUBY
  object do
    member :data do
      object_if true do
        member :foo, 'bar'
      end
    end 
  end
RUBY

puts JSONFactory.build(factory) # => { "data": { "foo": "bar" } }
```
```ruby
factory = <<-RUBY
  object do
    member :data do
      object_if false do
        member :foo, 'bar'
      end
    end 
  end
RUBY

puts JSONFactory.build(factory) # => { "data": null }
```

##### Load jfactory files

```ruby
# tmp/test.jfactory
member :id, test_object.id
member :name, test_object.name
``` 

```ruby
# test data
test_object = OpenStruct.new(id: '1', name: 'TestObject1')

puts JSONFactory.build('tmp/test.jfactory', object: test_object).build # => { "id": 1, name: "TestObject1" }
```   

## Development

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aklaiber/json_factory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

