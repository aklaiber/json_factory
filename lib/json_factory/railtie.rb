# frozen_string_literal: true

module JSONFactory
  class Railtie < Rails::Railtie
    initializer 'json_factory.cache' do |app|
      Cache.instance.store = Rails.cache
    end

    initializer 'json_factory.jfactory_watcher' do |app|
      jfactory_reloader = app.config.file_watcher.new(Dir.glob(::Rails.root.join('app/views/**/*.jfactory'))) do
        TemplateStore.instance.clear
      end

      app.reloaders << jfactory_reloader

      config.to_prepare do
        jfactory_reloader.execute_if_updated
      end
    end
  end
end
