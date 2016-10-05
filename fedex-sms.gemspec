# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fedex-sms/version"

Gem::Specification.new do |spec|
  spec.name          = "fedex-sms"
  spec.version       = FedexSMS::VERSION
  spec.authors       = ["Brian Abreu"]
  spec.email         = ["brian@nuts.com"]

  spec.license       = "MIT"
  spec.summary       = "FedEx Ship Manager Server integration library."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/nuts/fedex-sms"

  spec.executables   = %w(fsms)

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "nokogiri", "~> 1.6"
end
