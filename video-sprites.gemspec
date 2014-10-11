# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'video/sprites/version'

Gem::Specification.new do |spec|
  spec.name          = "video-sprites"
  spec.version       = Video::Sprites::VERSION
  spec.authors       = ["Ashley Blewer, Jay Brown, Jason Ronallo, Nick Zoss"]
  spec.email         = ["ashley.blewer@gmail.com, jlb1504@gmail.com, jronallo@gmail.com, nickzoss@yahoo.com"]
  spec.summary       = %q{Automatically generated thumbnail for video files.}
  spec.description   = %q{Automatically generated thumbnail for video files.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select{|file| file =~ /^test\/videos\// ? false : true}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "slop", "~> 3.3.3"
end
