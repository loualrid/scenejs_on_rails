# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scenejs_on_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "scenejs_on_rails"
  spec.version       = ScenejsOnRails::VERSION
  spec.authors     = ["Louis Alridge"]
  spec.email       = ["loualrid@gmail.com"]
  spec.homepage    = "https://github.com/loualrid/scenejs_on_rails"
  spec.summary     = %q{Scenejs On Rails Smart Asset Management}
  spec.description = <<-EOF
    ### Features ###
    * Allows you to utilize scenejs without having to clutter up your assets with tons of js files for self hosters.
    * Seamlessly allows you to create and utilize plugins you've made and placed in your vendor/assets/javascripts/scenejs_plugins directory
    * Preserves the directory structure of scenejs plugins, you can keep your custom made plugins in a place where scenejs
      can find them.
  EOF

  spec.rubyforge_project = "scenejs_on_rails"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rails', '>= 3.1.1'

  spec.license = 'MIT'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end