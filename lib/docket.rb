require 'active_support'
require 'active_support/core_ext'
require 'aws-sdk-core'
require 'colorize'

require 'docket/logging'
require 'docket/builder'
require 'docket/message_sanitizer'
require 'docket/console_sender'
require 'docket/topic'
require 'docket/topic_directory'
require 'docket/message_invalid'
require 'docket/message'
require 'docket/sns/subscription'

require 'docket/railtie' if defined?(Rails)

module Docket
  VERSION = '1.0.0'
  ROOT_PATH = File.dirname(File.dirname(__FILE__))

  module_function

  def topics
    @topics ||= config.topics
  end

  def env
    (ENV['RACK_ENV'] || ENV['RAILS_ENV'] || ENV['ENVOY_ENV'] || 'development').inquiry
  end

  def config
    @config ||= ActiveSupport::OrderedOptions.new.tap do |x|
      x.aws = ActiveSupport::OrderedOptions.new.tap do |aws|
        aws.credentials = {
          access_key_id: nil,
          secret_access_key: nil }
        aws.region    = 'eu-west-1'
        aws.endpoint  = nil
      end
      x.builder = ActiveSupport::OrderedOptions.new.tap do |builder|
        builder.path = nil
        builder.path = File.join(Rails.root, 'config', 'docket_manifest.yml') if defined?(Rails)
      end
      x.topics = TopicDirectory.new
    end
  end

  def configure(&block)
    yield(config)
  end

  def credentials
    @credentials ||= Aws::Credentials.new(config.aws.credentials[:access_key_id], config.aws.credentials[:secret_access_key])
  end

end
