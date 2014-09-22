require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'active_attr'
require 'aws-sdk-core'
require 'colorize'

require_relative 'docket/logging'
require_relative 'docket/console_sender'
require_relative 'docket/topic'
require_relative 'docket/message_invalid'
require_relative 'docket/message'

require_relative 'docket/railtie' if defined?(Rails)

module Docket
  VERSION = '1.1.0'
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
        aws.access_key = nil
        aws.secret_key = nil
        aws.region = 'eu-west-1'
      end

      x.sns = ActiveSupport::OrderedOptions.new.tap do |sns|
        sns.endpoint = nil
      end

      x.topics = Hash.new { |hash, key| Topic.new key }
    end
  end

  def configure(&block)
    yield(config)

    Aws.config[:credentials] = Aws::Credentials.new config.aws.access_key, config.aws.secret_key
    Aws.config[:region] = config.aws.region
  end
end
