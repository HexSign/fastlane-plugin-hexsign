# frozen_string_literal: true

require "fastlane/action"
require_relative "../helper/hexsign_helper"

module Fastlane
  module Actions
    class HexsignCertificatesDownloadAction < Action
      def self.run(params)
        args = ["certificates", "download", params[:id]]
        args.push("--output-dir", params[:output_dir]) if params[:output_dir]
        args.push("--filename", params[:filename]) if params[:filename]

        Helper::HexsignHelper.run(args).tap { UI.success("Downloaded certificate #{params[:id]}") }
      end

      def self.description
        "Download an Apple signing certificate (.p12 + .password) via the HexSign CLI."
      end

      def self.authors
        ["HexSign"]
      end

      def self.details
        <<~DETAILS
          Wraps `hexsign certificates download <id>`. The hexsign binary must be on PATH —
          install it with `brew install hexsign` or via the hexsign/hexsign-cli GitHub Action.

          Set HEXSIGN_CLIENT_ID and HEXSIGN_CLIENT_SECRET in the environment so the CLI runs
          in machine mode. See https://github.com/hexsign/hexsign-cli for token provisioning.
        DETAILS
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :id,
            env_name: "HEXSIGN_CERTIFICATE_ID",
            description: "Certificate ID to download",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :output_dir,
            env_name: "HEXSIGN_CERTIFICATE_OUTPUT_DIR",
            description: "Directory to write the .p12 and .password files into",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :filename,
            env_name: "HEXSIGN_CERTIFICATE_FILENAME",
            description: "Base filename (no extension) for the downloaded files",
            optional: true,
            type: String
          )
        ]
      end

      def self.is_supported?(platform)
        %i[ios mac tvos watchos visionos].include?(platform)
      end

      def self.example_code
        [
          'hexsign_certificates_download(id: "cert-abc123", output_dir: "build/sign")'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
