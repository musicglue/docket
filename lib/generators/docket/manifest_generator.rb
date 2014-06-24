require "rails/generators/named_base"

module Docket
  class ManifestGenerator < Rails::Generators::Base

    desc "Create the manifest for Docket"
    def copy_manifest_file
      copy_file "manifest.yml", "config/docket_manifest.yml"
    end

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'manifest/templates')
    end

  end
end
