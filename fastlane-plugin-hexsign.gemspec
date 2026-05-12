# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fastlane/plugin/hexsign/version"

Gem::Specification.new do |spec|
  spec.name          = "fastlane-plugin-hexsign"
  spec.version       = Fastlane::Hexsign::VERSION
  spec.author        = "HexSign"
  spec.email         = "support@hexsign.io"

  spec.summary       = "Fastlane actions for HexSign — fetch Apple signing material from your lanes."
  spec.homepage      = "https://github.com/hexsign/fastlane-plugin-hexsign"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w[README.md LICENSE]
  spec.require_paths = ["lib"]
  spec.metadata = {
    "homepage_uri" => "https://hexsign.io",
    "source_code_uri" => "https://github.com/hexsign/fastlane-plugin-hexsign",
    "bug_tracker_uri" => "https://github.com/hexsign/fastlane-plugin-hexsign/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.required_ruby_version = ">= 3.0"

  spec.add_development_dependency("fastlane", ">= 2.210.0")
  spec.add_development_dependency("rake", "~> 13.0")
  spec.add_development_dependency("rspec", "~> 3.12")
  spec.add_development_dependency("rubocop", "~> 1.50")
end
