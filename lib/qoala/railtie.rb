module Qoala
  class Railtie < Rails::Railtie

    initializer :set_load_paths do |app|
      app.config.autoload_paths << File.dirname(__FILE__) + "/controller.rb"
    end

    initializer :add_routing_paths do |app|
      app.routes_reloader.paths.unshift File.dirname(__FILE__) + "/routes.rb"
    end

  end
end
