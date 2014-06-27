require 'rails'

module Docket
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.join(Docket::ROOT_PATH, 'lib', 'tasks', 'docket.rake')
    end
  end
end
