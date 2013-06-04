# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'btsync/version'

Gem::Specification.new do |spec|
  spec.name          = "btsync"
  spec.version       = Btsync::VERSION
  spec.authors       = ["Chris MacNaughton"]
  spec.email         = ["chmacnaughton@gmail.com"]
  spec.description   = %q{Class to interact with BTSync's web interface}
  spec.summary       = %q{Class to interact with BTSync's web interface}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "httparty"
end
