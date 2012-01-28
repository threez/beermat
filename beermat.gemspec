# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "beermat/version"

Gem::Specification.new do |s|
  s.name        = "beermat"
  s.version     = Beermat::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Vincent Landgraf"]
  s.email       = ["vilandgr@googlemail.com"]
  s.homepage    = ""
  s.summary     = %q{Beermat comsume tracking}
  s.description = %q{Track the beer and wine consume of your group}

  s.rubyforge_project = "beermat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency('sinatra')
  s.add_development_dependency('rspec')
end
