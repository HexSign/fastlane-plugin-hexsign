# frozen_string_literal: true

require "fastlane/action"
require_relative "../helper/hexsign_helper"

module Fastlane
  module Actions
    class HexsignProfilesDownloadByBundleIdAction < Action
      def self.run(params)
        args = ["profiles", "download", "--bundle-id", params[:bundle_id]]
        args.push("--team-id", params[:team_id]) if params[:team_id]
        args.push("--output-dir", params[:output_dir]) if params[:output_dir]

        stdout = Helper::HexsignHelper.run(args)
        paths = stdout.split("\n").map(&:strip).reject(&:empty?)

        UI.success("Downloaded #{paths.size} provisioning profile(s) for bundle #{params[:bundle_id]}")
        paths
      end

      def self.description
        "Download every provisioning profile for a given bundle identifier via the HexSign CLI."
      end

      def self.authors
        ["HexSign"]
      end

      def self.details
        <<~DETAILS
          Wraps `hexsign profiles download --bundle-id <ID> [--team-id <TID>]`. Returns an
          array of absolute paths to the downloaded `.mobileprovision` files.

          Survives profile rotation: you point at a bundle identifier rather than the
          UUID of a specific provisioning profile.

          Pass `team_id` when the same bundle id exists in more than one linked Apple
          account to avoid pulling profiles from the wrong team.

          The hexsign binary must be on PATH — install via `brew install hexsign` or the
          hexsign/hexsign-cli GitHub Action. Set HEXSIGN_CLIENT_ID and HEXSIGN_CLIENT_SECRET
          so the CLI runs in machine mode.
        DETAILS
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :bundle_id,
            env_name: "HEXSIGN_BUNDLE_ID",
            description: "App bundle identifier (exact match)",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :team_id,
            env_name: "HEXSIGN_TEAM_ID",
            description: "Apple Developer team identifier — scopes the download across linked accounts",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_dir,
            env_name: "HEXSIGN_PROFILE_OUTPUT_DIR",
            description: "Directory to write the .mobileprovision files into",
            optional: true,
            type: String
          )
        ]
      end

      def self.return_value
        "Array of absolute paths to the downloaded .mobileprovision files."
      end

      def self.is_supported?(platform)
        %i[ios mac tvos watchos visionos].include?(platform)
      end

      def self.example_code
        [
          'paths = hexsign_profiles_download_by_bundle_id(
            bundle_id: "com.example.app",
            team_id: "ABCDE12345",
            output_dir: "build/sign"
          )
          # => ["build/sign/foo.mobileprovision", "build/sign/bar.mobileprovision"]'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
