# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "speedy_c2dm/version"

Gem::Specification.new do |s|
  s.name        = "speedy_c2dm"
  s.version     = SpeedyC2dm::VERSION
  s.authors     = ["Sandeep Ghael"]
  s.email       = ["sghael@ravidapp.com"]
  s.homepage    = ""
  s.summary     = %q{Speedy C2DM is an intelligent gem for sending push notifications to Android devices via Google C2DM.}
  s.description = %q{Speedy C2DM efficiently sends push notifications to Android devices via google c2dm.}

  s.rubyforge_project = "speedy_c2dm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
