lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |gem|
  gem.name          = "decorated_graph"
  gem.version       = DecoratedGraph::VERSION
  gem.authors       = ["Quoc_Anh Nguyen"]
  gem.email         = ["anh59@aol.com"]
  gem.description   = %q{Library to create graphs in Prawn with many features}
  gem.summary       = %q{Library to create graphs in Prawn with many features}
  gem.homepage      = ""

  gem.add_dependency "prawn"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
