# frozen_string_literal: true

describe Fastlane::Actions::HexsignCertificatesDownloadByTypeAction do
  let(:helper) { Fastlane::Helper::HexsignHelper }

  before { helper.reset! }

  describe "#run" do
    it "shells out with --type, --team-id, and --output-dir" do
      expect(helper).to receive(:run)
        .with(["certificates", "download", "--type", "IOS_DISTRIBUTION", "--team-id", "ABCDE12345", "--output-dir", "build/sign"])
        .and_return("build/sign/foo.p12\nbuild/sign/foo.password\nbuild/sign/bar.p12\nbuild/sign/bar.password\n")

      result = Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_certificates_download_by_type(
            type: "IOS_DISTRIBUTION",
            team_id: "ABCDE12345",
            output_dir: "build/sign"
          )
        end
      LANE

      expect(result).to eq([
                             { p12: "build/sign/foo.p12", password: "build/sign/foo.password" },
                             { p12: "build/sign/bar.p12", password: "build/sign/bar.password" }
                           ])
    end

    it "omits --output-dir when not provided" do
      expect(helper).to receive(:run)
        .with(%w[certificates download --type IOS_DISTRIBUTION --team-id ABCDE12345])
        .and_return("")

      Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_certificates_download_by_type(
            type: "IOS_DISTRIBUTION",
            team_id: "ABCDE12345"
          )
        end
      LANE
    end

    it "returns an empty array when the CLI prints nothing (no certs matched)" do
      allow(helper).to receive(:run).and_return("")

      result = Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_certificates_download_by_type(
            type: "IOS_DISTRIBUTION",
            team_id: "ABCDE12345"
          )
        end
      LANE

      expect(result).to eq([])
    end

    it "tolerates trailing whitespace and blank lines around the path pairs" do
      stdout = "\n  build/sign/foo.p12  \n  build/sign/foo.password \n\n"
      allow(helper).to receive(:run).and_return(stdout)

      result = Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_certificates_download_by_type(
            type: "IOS_DISTRIBUTION",
            team_id: "ABCDE12345"
          )
        end
      LANE

      expect(result).to eq([
                             { p12: "build/sign/foo.p12", password: "build/sign/foo.password" }
                           ])
    end

    it "errors with an install hint when hexsign is not on PATH" do
      allow(helper).to receive(:which).and_return(nil)

      expect do
        Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
          lane :test do
            hexsign_certificates_download_by_type(type: "IOS_DISTRIBUTION", team_id: "ABCDE12345")
          end
        LANE
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /hexsign binary not found/)
    end
  end
end
