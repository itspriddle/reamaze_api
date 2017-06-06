require_relative "lib/reamaze_api/version"

Gem::Specification.new do |spec|
  spec.name          = "reamaze_api"
  spec.version       = ReamazeAPI::VERSION
  spec.authors       = ["Joshua Priddle"]
  spec.email         = ["jpriddle@me.com"]
  spec.license       = "MIT"

  spec.summary       = %q{Reamaze API client}
  spec.description   = %q{Reamaze API client}
  spec.homepage      = "https://github.com/itspriddle/reamaze_api"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\Atest/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.2.0"

  spec.add_dependency "faraday",            ">= 0.9.2", "< 1.0"
  spec.add_dependency "faraday_middleware", ">= 0.9.0", "< 1.0"

  spec.add_development_dependency "bundler",     "~> 1.12"
  spec.add_development_dependency "rake",        "~> 10.0"
  spec.add_development_dependency "minitest",    "~> 5.9.0"
  spec.add_development_dependency "rake-tomdoc", "~> 0.0.2"
end
