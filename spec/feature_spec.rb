require "spec_helper"
require 'wimdu'

describe "Wimdu CLI" do
  let(:exe) { File.expand_path('../../bin/wimdu', __FILE__) }

  describe "new" do
    let(:cmd) { "#{exe} new" }

    it "allows for entering data" do
      process = run_interactive(cmd)
      expect(process.output).to include("Starting with new property")
      expect(process.output).to include("Title: ")
      type "My Title"
      expect(process.output).to include("Address: ")
    end
  end

  describe "continue" do
    let(:cmd) { "#{exe} continue" }

    it "disallows for continuing data input for non-existing" do
      uuid = SecureRandom.hex(4).upcase
      process = run_interactive("#{cmd} #{uuid}")
      expect(process.output).to include("Cannot find property with #{uuid}")
    end
  end

  describe "list" do
    let(:cmd) { "#{exe} list" }

    it "list some data" do
      process = run_interactive(cmd)
      expect(process.output).to include("Found")
    end
  end

end
