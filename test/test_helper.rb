ENV['RAILS_ENV'] ||= 'test'

require 'awesome_print'

require 'minitest'
require 'minitest/spec'

require 'minitest/focus'
require 'minitest/rg'
require 'minitest/autorun'

require_relative '../lib/docket'
