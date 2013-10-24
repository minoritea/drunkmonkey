# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drunkmonkey/version'

Gem::Specification.new do |spec|
  spec.name          = "drunkmonkey"
  spec.version       = DrunkMonkey::VERSION
  spec.authors       = ["Minori Tokuda"]
  spec.email         = ["minorityland@gmail.jp"]
  spec.description   = <<-EOS
    DrunkMonkey is a rack middleware providing realtime two-way http communication with API for Portal, a javascript messaging library.
    It provides just two protocols currently; websocket and longpoll comet.
    You can write code once for each protocols.
  EOS
  spec.summary       = %q{DrunkMonkey is a rack middleware providing realtime two-way http communication with API for Portal.}
  spec.homepage      = "https://github.com/minoritea/drunkmonkey"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "celluloid", ">= 0.15"
  spec.add_dependency "rack", ">= 1.5"
  spec.add_dependency "websocket", ">= 1.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
