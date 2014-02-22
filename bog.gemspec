# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bog/version'

Gem::Specification.new do |spec|
  spec.name          = "bog"
  spec.version       = Bog::VERSION
  spec.authors       = ["Tom Corelis"]
  spec.email         = ["tom@tomcorelis.com"]
  spec.description   = %q{Logging library for Ruby projects with colorization and caller introspection}
  spec.summary       = %q{Logging library for Ruby projects with colorization and caller introspection}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
