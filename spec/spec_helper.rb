# frozen_string_literal: true

require "fastlane"
require "fastlane/plugin/hexsign"

Fastlane.load_actions

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
