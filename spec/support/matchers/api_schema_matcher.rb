# frozen_string_literal: true

RSpec::Matchers.define :match_response_schema do |schema|
  match do |json|
    JSON::Validator.validate!("#{Dir.pwd}/spec/fixtures/schemas/#{schema}", json, strict: true)
  end
end
