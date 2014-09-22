# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "docket"
  spec.version       = '1.1.0'
  spec.authors       = ["Adam Carlile"]
  spec.email         = ["adam@benchmedia.co.uk"]
  spec.summary       = %q{Sends messages to SNS.}
  spec.description   = %q{Sends messages to SNS.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'active_attr'
  spec.add_runtime_dependency 'activemodel'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'aws-sdk-core'
  spec.add_runtime_dependency 'colorize'

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'minitest-rg'
  spec.add_development_dependency 'rake'
end
