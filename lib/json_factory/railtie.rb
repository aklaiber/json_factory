# frozen_string_literal: true

module JSONFactory
  class Railtie < Rails::Railtie
    initializer :json_factory do
      Cache.instance.store = Rails.cache
    end
  end
end
