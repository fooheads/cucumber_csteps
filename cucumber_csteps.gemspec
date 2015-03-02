# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cucumber_csteps/version'

Gem::Specification.new do |spec|
  spec.name          = "cucumber_csteps"
  spec.version       = CucumberCsteps::VERSION
  spec.authors       = ["Jon-Erling Dahl", "Niclas Nilsson"]
  spec.email         = ["jon-erling@fooheads.com", "niclas@fooheads.com"]
  spec.summary       = %q{Cucumber steps in C/C++}
  spec.description   = %q{Write your Cucumber steps in C/C++}
  spec.homepage      = "https://github.com/fooheads/cucumber_csteps"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "dp", "~> 1.0.1"

  spec.add_dependency "parslet", "~> 1.6"
  spec.add_dependency "activesupport", "~> 4.2"
  spec.add_dependency "cucumber", "~> 1.3"
  spec.add_dependency "ffi", "~> 1.9"
end

