# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-factor"
  gem.version       = "1.0.0"
  gem.authors       = ["Yuki Kuwabara"]
  gem.email         = ["eramuk@gmail.com"]
  gem.summary       = "input plugin for gathering factor"
  gem.description   = gem.summary
  gem.homepage      = "https://github.com/eramuk/fluent-plugin-factor"
  gem.licenses      = ["MIT"]

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd", ">= 0.14.0"
  gem.add_runtime_dependency "facter", "~> 2.4", ">= 2.4.6"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit"
end
