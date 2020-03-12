# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "nixer-docs-theme"
  spec.version       = "0.1.0"
  spec.authors       = ["nixer.io"]
  spec.email         = ["contact@nixer.io"]

  spec.summary       = "Nixer documentation"
  spec.homepage      = "https://github.com/nixer-io/nixer-io.github.io"
  spec.license       = "MIT"

  spec.metadata["plugin_type"] = "theme"

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(assets|_(includes|layouts|sass)/|(LICENSE|README)((\.(txt|md|markdown)|$)))}i)
  end

  spec.add_runtime_dependency "jekyll", "~> 3.8.5"
  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 12.3"
end
