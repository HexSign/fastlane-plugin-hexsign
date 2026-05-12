# frozen_string_literal: true

require "fastlane/plugin/hexsign/version"

module Fastlane
  module Hexsign
    # Auto-load every action and helper in this gem so Fastlane can discover them.
    def self.all_classes
      Dir[File.expand_path("hexsign/**/*.rb", __dir__)]
    end
  end
end

Fastlane::Hexsign.all_classes.each { |f| require f }
