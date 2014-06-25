require 'rails'

module Docket
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(Docket::ROOT_PATH, 'lib', 'tasks', 'builder.rake')
    end
  end
end
