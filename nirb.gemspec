# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nirb/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniel Nordstrom"]
  gem.email         = ["d@nintera.com"]
  gem.description   = %q{The tiny little spare framework.}
  gem.summary       = %q{Tiny little spare framework for quick and easy Ruby web development.}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "nirb"
  gem.require_paths = ["lib"]
  gem.version       = Nirb::VERSION
end
