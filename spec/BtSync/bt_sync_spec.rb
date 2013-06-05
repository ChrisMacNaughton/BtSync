require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'btsync'
describe 'BtSync' do
  before(:each) do
    VCR.use_cassette("Setup-BtSync") do
      @bt = BtSync.new
    end
  end

  it "can view a folder list" do
    VCR.use_cassette("get-folders") do
      @folder = @bt.get_folders.first
    end
    @folder.name.should == "/home/chris/Documents"
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
  it "can add and delete a folder" do
    VCR.use_cassette("add-folder") do
      @bt.add_folder '/home/chris/bt_test'
    end
    VCR.use_cassette("add-folder-list") do
      folders = @bt.get_folders
      folders.count.should == 2
      folder = folders.last
      folder.name.should == "/home/chris/bt_test"
    end
    VCR.use_cassette("remove-folder") do
      @bt.remove_folder '/home/chris/bt_test'
    end
    VCR.use_cassette("remove-folder-list") do
      folders = @bt.get_folders
      folders.count.should == 1
      folder = folders.last
      folder.name.should == "/home/chris/Documents"
    end
  end
end