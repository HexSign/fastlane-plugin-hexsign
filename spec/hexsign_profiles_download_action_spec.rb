# frozen_string_literal: true

describe Fastlane::Actions::HexsignProfilesDownloadAction do
  let(:helper) { Fastlane::Helper::HexsignHelper }

  before { helper.reset! }

  describe "#run" do
    it "shells out with id, --output-dir, and --filename" do
      expect(helper).to receive(:run)
        .with(["profiles", "download", "prof-1", "--output-dir", "build/sign", "--filename", "match-AppStore"])
        .and_return("")

      Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_profiles_download(
            id: "prof-1",
            output_dir: "build/sign",
            filename: "match-AppStore"
          )
        end
      LANE
    end

    it "omits optional flags when not provided" do
      expect(helper).to receive(:run)
        .with(%w[profiles download prof-1])
        .and_return("")

      Fastlane::FastFile.new.parse(<<~LANE).runner.execute(:test)
        lane :test do
          hexsign_profiles_download(id: "prof-1")
        end
      LANE
    end
  end
end
