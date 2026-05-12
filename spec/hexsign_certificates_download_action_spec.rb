# frozen_string_literal: true

describe Fastlane::Actions::HexsignCertificatesDownloadAction do
  let(:helper) { Fastlane::Helper::HexsignHelper }

  before { helper.reset! }

  describe "#run" do
    it "shells out with id, --output-dir, and --filename" do
      expect(helper).to receive(:run)
        .with(["certificates", "download", "cert-1", "--output-dir", "build/sign", "--filename", "dev"])
        .and_return("")

      Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_certificates_download(
            id: "cert-1",
            output_dir: "build/sign",
            filename: "dev"
          )
        end
      LANE
    end

    it "omits optional flags when not provided" do
      expect(helper).to receive(:run)
        .with(%w[certificates download cert-1])
        .and_return("")

      Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_certificates_download(id: "cert-1")
        end
      LANE
    end

    it "errors with an install hint when hexsign is not on PATH" do
      allow(helper).to receive(:which).and_return(nil)

      expect do
        Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
          lane :test do
            hexsign_certificates_download(id: "cert-1")
          end
        LANE
      end.to raise_error(FastlaneCore::Interface::FastlaneError, /hexsign binary not found/)
    end
  end
end
