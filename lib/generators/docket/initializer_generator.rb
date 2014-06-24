require "rails/generators/named_base"

module Docket
  class InitializerGenerator < Rails::Generators::Base

    desc "Create the manifest for Docket"
    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/docket.rb"
    end

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'initializer/templates')
    end

  end
end
