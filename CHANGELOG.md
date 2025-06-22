# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD workflow for automated testing
- RuboCop configuration for code style enforcement
- Multi-Ruby version testing (3.0, 3.1, 3.2, 3.3)
- Automated gem building and artifact upload
- Code style improvements and standardization

### Changed
- Updated .gitignore to exclude built gems and CI logs
- Improved code formatting and style consistency
- Enhanced gemspec with security requirements (MFA)

## [0.1.0] - 2025-06-22

### Added
- Initial release of CompositeValidator
- Support for validating single associated models with `validates :field, composite: true`
- Support for validating collections of models
- Support for validation contexts with `validates :field, composite: { context: :publish }`
- Automatic nil handling (skips validation when value is nil)
- Error message aggregation from associated models
- Comprehensive test suite with RSpec
- Documentation and usage examples
- MIT license
