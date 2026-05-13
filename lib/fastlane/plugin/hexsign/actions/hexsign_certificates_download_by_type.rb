# frozen_string_literal: true

require "fastlane/action"
require_relative "../helper/hexsign_helper"

module Fastlane
  module Actions
    class HexsignCertificatesDownloadByTypeAction < Action
      def self.run(params)
        args = [
          "certificates", "download",
          "--type", params[:type],
          "--team-id", params[:team_id]
        ]
        args.push("--output-dir", params[:output_dir]) if params[:output_dir]

        stdout = Helper::HexsignHelper.run(args)
        pairs = parse_stdout(stdout)

        UI.success("Downloaded #{pairs.size} #{params[:type]} certificate(s) for team #{params[:team_id]}")
        pairs
      end

      # The CLI prints two lines per certificate: .p12 path then .password path.
      # Returns [{ p12: "...", password: "..." }, ...].
      def self.parse_stdout(stdout)
        lines = stdout.split("\n").map(&:strip).reject(&:empty?)
        pairs = []
        lines.each_slice(2) do |p12, password|
          pairs << { p12: p12, password: password }
        end
        pairs
      end

      def self.description
        "Download every signing certificate of a given type for one Apple Developer team via the HexSign CLI."
      end

      def self.authors
        ["HexSign"]
      end

      def self.details
        <<~DETAILS
          Wraps `hexsign certificates download --type <T> --team-id <ID>`. Returns an
          array of { p12:, password: } hashes — one per downloaded certificate.

          Survives certificate rotation: you point at a cert type (e.g. IOS_DISTRIBUTION)
          rather than a specific UUID that changes when a cert is renewed.

          The hexsign binary must be on PATH — install via `brew install hexsign` or the
          hexsign/hexsign-cli GitHub Action. Set HEXSIGN_CLIENT_ID and HEXSIGN_CLIENT_SECRET
          so the CLI runs in machine mode.

          Accepted types: IOS_DEVELOPMENT, IOS_DISTRIBUTION, MAC_APP_DEVELOPMENT,
          MAC_APP_DISTRIBUTION, MAC_INSTALLER_DISTRIBUTION, DEVELOPER_ID_APPLICATION,
          DEVELOPER_ID_APPLICATION_G2, DEVELOPER_ID_KEXT, DEVELOPER_ID_KEXT_G2,
          DEVELOPER_ID_INSTALLER, DEVELOPMENT, DISTRIBUTION, PASS_TYPE_ID,
          PASS_TYPE_ID_WITH_NFC.
        DETAILS
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :type,
            env_name: "HEXSIGN_CERTIFICATE_TYPE",
            description: "Apple certificate type, e.g. IOS_DISTRIBUTION",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :team_id,
            env_name: "HEXSIGN_TEAM_ID",
            description: "Apple Developer team identifier to scope the download to",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_dir,
            env_name: "HEXSIGN_CERTIFICATE_OUTPUT_DIR",
            description: "Directory to write the .p12 and .password files into",
            optional: true,
            type: String
          )
        ]
      end

      def self.output
        [
          ["HEXSIGN_CERTIFICATES_DOWNLOAD_BY_TYPE_COUNT", "Number of certificates downloaded"]
        ]
      end

      def self.return_value
        "Array of { p12:, password: } hashes — one per downloaded certificate."
      end

      def self.is_supported?(platform)
        %i[ios mac tvos watchos visionos].include?(platform)
      end

      def self.example_code
        [
          'pairs = hexsign_certificates_download_by_type(
            type: "IOS_DISTRIBUTION",
            team_id: "ABCDE12345",
            output_dir: "build/sign"
          )
          # => [{ p12: "build/sign/foo.p12", password: "build/sign/foo.password" }, ...]'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
