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
      @folder = @bt.folders.first
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
  it "can get listening port" do
    VCR.use_cassette("get-settings") do
      @bt.listening_port.should == 63754
    end
  end
  it "can get upload limit" do
    VCR.use_cassette("get-settings") do
      @bt.upload_limit.should == 0
    end
  end
  it "can get download limit" do
    VCR.use_cassette("get-settings") do
      @bt.download_limit.should == 0
    end
  end
  it "can get device name" do
    VCR.use_cassette("get-settings") do
      @bt.device_name.should == "IceyEC-Virtual1"
    end
  end
  it "can change the device_name" do
    VCR.use_cassette("change_name") do
      @bt.device_name = "IceyEC-Virtual2"
      @bt.device_name.should == "IceyEC-Virtual2"
    end
    VCR.use_cassette('reset_device_name') do
      @bt.device_name = "IceyEC-Virtual1"
      @bt.device_name.should == "IceyEC-Virtual1"
    end
  end
  it "can change the upload limit" do
    VCR.use_cassette("change_upload_limit") do
      @bt.upload_limit = 1000
      @bt.upload_limit.should == 1000
    end
    VCR.use_cassette('reset_upload_limit') do
      @bt.upload_limit = 0
      @bt.upload_limit.should == 0
    end
  end
  it "can change the download limit" do
    VCR.use_cassette("change_download_limit") do
      @bt.download_limit = 1000
      @bt.download_limit.should == 1000
    end
    VCR.use_cassette('reset_download_limit') do
      @bt.download_limit = 0
      @bt.download_limit.should == 0
    end
  end
  it "can change the listening_port" do
    VCR.use_cassette("change_listening_port") do
      @bt.listening_port = 12345
      @bt.listening_port.should == 12345
    end
    VCR.use_cassette('reset_listening_port') do
      @bt.listening_port = 63754
      @bt.listening_port.should == 63754
    end
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
      folders = @bt.folders
      folders.count.should == 2
      folder = folders.last
      folder.name.should == "/home/chris/bt_test"
    end
    VCR.use_cassette("remove-folder") do
      @bt.remove_folder '/home/chris/bt_test'
    end
    VCR.use_cassette("remove-folder-list") do
      folders = @bt.folders
      folders.count.should == 1
      folder = folders.last
      folder.name.should == "/home/chris/Documents"
    end
  end
end