# frozen_string_literal: true

require "fileutils"
require "tmpdir"

describe Fastlane::Helper::HexsignHelper do
  let(:helper) { described_class }

  before { helper.reset! }
  after  { helper.reset! }

  describe ".which" do
    it "finds an executable on PATH" do
      Dir.mktmpdir do |dir|
        bin = File.join(dir, "fakebin")
        File.write(bin, "#!/bin/sh\necho hi\n")
        File.chmod(0o755, bin)

        with_path(dir) do
          expect(helper.which("fakebin")).to eq(bin)
        end
      end
    end

    it "returns nil when the executable is not on PATH" do
      Dir.mktmpdir do |dir|
        with_path(dir) do
          expect(helper.which("definitely-not-on-path")).to be_nil
        end
      end
    end

    it "skips directories that happen to share the name" do
      Dir.mktmpdir do |dir|
        FileUtils.mkdir(File.join(dir, "namesake"))
        with_path(dir) do
          expect(helper.which("namesake")).to be_nil
        end
      end
    end
  end

  describe ".find_binary" do
    it "raises a fastlane error with an install hint when hexsign is missing" do
      allow(helper).to receive(:which).and_return(nil)
      expect { helper.find_binary }.to raise_error(FastlaneCore::Interface::FastlaneError) do |err|
        expect(err.message).to include("hexsign binary not found")
        expect(err.message).to include("brew install hexsign")
      end
    end

    it "memoises the resolved path across calls" do
      allow(helper).to receive(:which).and_return("/usr/local/bin/hexsign").once
      expect(helper.binary_path).to eq("/usr/local/bin/hexsign")
      expect(helper.binary_path).to eq("/usr/local/bin/hexsign")
    end
  end

  describe ".run" do
    before { allow(helper).to receive(:binary_path).and_return("/fake/hexsign") }

    it "returns stdout on successful invocation" do
      allow(Open3).to receive(:capture3)
        .with("/fake/hexsign", "version")
        .and_return(["hexsign 1.2.3\n", "", instance_double(Process::Status, success?: true, exitstatus: 0)])

      expect(helper.run(["version"])).to eq("hexsign 1.2.3\n")
    end

    it "raises a fastlane error with the exit code on failure" do
      allow(Open3).to receive(:capture3)
        .and_return(["", "boom\n", instance_double(Process::Status, success?: false, exitstatus: 7)])

      expect { helper.run(["broken"]) }
        .to raise_error(FastlaneCore::Interface::FastlaneError, /status 7/)
    end

    it "surfaces stderr to the user on failure" do
      allow(Open3).to receive(:capture3)
        .and_return(["", "auth: invalid client\n", instance_double(Process::Status, success?: false, exitstatus: 1)])

      expect(FastlaneCore::UI).to receive(:error).with("auth: invalid client")
      expect { helper.run(["whatever"]) }.to raise_error(FastlaneCore::Interface::FastlaneError)
    end

    it "stays silent when stderr is empty on failure" do
      allow(Open3).to receive(:capture3)
        .and_return(["", "", instance_double(Process::Status, success?: false, exitstatus: 2)])

      expect(FastlaneCore::UI).not_to receive(:error)
      expect { helper.run(["x"]) }.to raise_error(FastlaneCore::Interface::FastlaneError, /status 2/)
    end
  end

  def with_path(dir)
    original = ENV["PATH"]
    ENV["PATH"] = dir
    yield
  ensure
    ENV["PATH"] = original
  end
end
