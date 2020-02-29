
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gitlab/release/version"

Gem::Specification.new do |spec|
  spec.name          = "gitlab-release-tools"
  spec.version       = Gitlab::Release::VERSION
  spec.authors       = ["Andrea Del Fante"]
  spec.email         = ["andreadelfante94@gmail.com"]

  spec.summary       = "Automation gitlab release tools made simple."
  spec.description   = "Automation gitlab release tools from MR and issues for your new versions."
  spec.homepage      = "https://github.com/andreadelfante/gitlab-release-tools"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/andreadelfante/gitlab-release-tools"
    spec.metadata["changelog_uri"] = "https://github.com/andreadelfante/gitlab-release-tools/blob/master/CHANGELOG.md##{Gitlab::Release::VERSION}"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  #spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "gitlab", "~> 4.12.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
end
