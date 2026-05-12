# frozen_string_literal: true

require "fastlane_core/ui/ui"
require "open3"
require "shellwords"

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class HexsignHelper
      INSTALL_HINT = "Install it with `brew install hexsign` or via the hexsign/hexsign-cli GitHub Action."

      def self.binary_path
        @binary_path ||= find_binary
      end

      # Resets memoization. Tests only.
      def self.reset!
        @binary_path = nil
      end

      def self.find_binary
        path = which("hexsign")
        UI.user_error!("hexsign binary not found on PATH. #{INSTALL_HINT}") if path.nil?
        path
      end

      def self.which(cmd)
        exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
        ENV["PATH"].to_s.split(File::PATH_SEPARATOR).each do |dir|
          exts.each do |ext|
            candidate = File.join(dir, "#{cmd}#{ext}")
            return candidate if File.executable?(candidate) && !File.directory?(candidate)
          end
        end
        nil
      end

      # Runs the CLI and returns stdout. Raises FastlaneCore::Interface::FastlaneError
      # on non-zero exit, surfacing stderr to the user.
      def self.run(args)
        cmd = [binary_path, *args]
        UI.command(cmd.shelljoin)
        stdout, stderr, status = Open3.capture3(*cmd)
        unless status.success?
          UI.error(stderr.strip) unless stderr.strip.empty?
          UI.user_error!("hexsign exited with status #{status.exitstatus}")
        end
        stdout
      end
    end
  end
end
