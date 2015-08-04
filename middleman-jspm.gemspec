# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "middleman-jspm/version"

Gem::Specification.new do |spec|
  spec.name          = "middleman-jspm"
  spec.version       = Middleman::JSPM::VERSION
  spec.authors       = ['Andrew Pilsch']
  spec.email         = ['apilsch@tamu.edu']
  spec.summary       = "Use JSPM in Middleman"
  spec.description   = "Use JSPM in Middleman"
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency 'middleman-core', '>= 3.2'
  spec.add_dependency 'uglifier'
  spec.add_dependency 'ejs'
end