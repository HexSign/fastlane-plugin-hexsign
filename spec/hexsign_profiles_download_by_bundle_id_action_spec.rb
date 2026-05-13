# frozen_string_literal: true

describe Fastlane::Actions::HexsignProfilesDownloadByBundleIdAction do
  let(:helper) { Fastlane::Helper::HexsignHelper }

  before { helper.reset! }

  describe "#run" do
    it "shells out with --bundle-id, --team-id, and --output-dir" do
      expect(helper).to receive(:run)
        .with(["profiles", "download", "--bundle-id", "com.example.app", "--team-id", "ABCDE12345", "--output-dir", "build/sign"])
        .and_return("build/sign/foo.mobileprovision\nbuild/sign/bar.mobileprovision\n")

      result = Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_profiles_download_by_bundle_id(
            bundle_id: "com.example.app",
            team_id: "ABCDE12345",
            output_dir: "build/sign"
          )
        end
      LANE

      expect(result).to eq([
        "build/sign/foo.mobileprovision",
        "build/sign/bar.mobileprovision"
      ])
    end

    it "omits --team-id and --output-dir when not provided" do
      expect(helper).to receive(:run)
        .with(%w[profiles download --bundle-id com.example.app])
        .and_return("")

      Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_profiles_download_by_bundle_id(bundle_id: "com.example.app")
        end
      LANE
    end

    it "errors with an install hint when hexsign is not on PATH" do
      allow(helper).to receive(:which).and_return(nil)

      expect do
        Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
          lane :test do
            hexsign_profiles_download_by_bundle_id(bundle_id: "com.example.app")
          end
        LANE
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /hexsign binary not found/)
    end
  end
end
