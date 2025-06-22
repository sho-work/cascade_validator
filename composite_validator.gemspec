# frozen_string_literal: true

require_relative "lib/composite_validator/version"

Gem::Specification.new do |spec|
  spec.name = "composite_validator"
  spec.version = CompositeValidator::VERSION
  spec.authors = ["sho-work"]
  spec.email = ["sho-work@example.com"]

  spec.summary = "ActiveModel validator for composing validations from associated models"
  spec.description = "CompositeValidator allows you to validate associated models and compose their validation errors to the parent model. It supports both single associations and collections."
  spec.homepage = "https://github.com/sho-work/composite_validator"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sho-work/composite_validator"
  spec.metadata["changelog_uri"] = "https://github.com/sho-work/composite_validator/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob([
    "lib/**/*",
    "LICENSE.txt",
    "README.md",
    "CHANGELOG.md"
  ])
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activemodel", ">= 5.2"
  spec.add_dependency "activesupport", ">= 5.2"

  # Development dependencies
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "rubocop-rspec", "~> 2.0"
end
