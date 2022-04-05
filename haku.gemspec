# frozen_string_literal: true

require_relative "lib/haku/version"

Gem::Specification.new do |spec|
  #
  ## INFORMATION
  #
  spec.name = "haku"
  spec.version = Haku.version
  spec.summary = "Write a short summary, because RubyGems requires one."
  spec.description = "Write a longer description or delete this line."
  spec.homepage = "https://github.com/javierav/haku"
  spec.license = "MIT"

  #
  ## OWNERSHIP
  #
  spec.authors = ["Javier Aranda"]
  spec.email = ["javier.aranda.varo@gmail.com"]

  #
  ## METADATA
  #
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/javierav/haku/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "https://github.com/javierav/haku/blob/v#{spec.version}/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  #
  ## GEM
  #
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  #
  ## DOCUMENTATION
  #
  spec.extra_rdoc_files = %w[LICENSE README.md]
  spec.rdoc_options     = ["--charset=UTF-8"]

  #
  ## REQUIREMENTS
  #
  spec.required_ruby_version = ">= 2.6.0"
end
