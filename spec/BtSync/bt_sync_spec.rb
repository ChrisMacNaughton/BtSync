require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'btsync'
describe 'BtSync' do
  before do
    VCR.use_cassette("Setup-BtSync") do
      @bt = BtSync.new
    end
  end
  it "can view a folder list" do
    VCR.use_cassette("get-folders") do
      @folder = @bt.get_folders.first
    end
    @folder["secret"].should == "KLXT6ZZBEABLFIL6X7VBHT7YA4YQQOJM"
    @folder["peers"].should == []
    @folder["size"].should == "21 B in 1 files"
  end
  it "can view settings" do
    VCR.use_cassette("get-settings") do
      @settings = @bt.get_settings
    end
    @settings["devicename"].should == "IceyEC-Virtual1"
    @settings["listeningport"].should == 63754
  end
  it "can check the OS" do
    VCR.use_cassette("get-os-type") do
      @os = @bt.get_os_type
    end
    @os.should == "linux"
  end
  it "can get the version" do
    VCR.use_cassette("get-version") do
      @version = @bt.get_version
    end
    @version.should == 16777350
  end
end