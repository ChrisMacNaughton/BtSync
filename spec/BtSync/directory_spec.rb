require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'BtSync::Directory' do
  before(:each) do
    VCR.use_cassette("Setup-BtSync-Directory") do
      @bt = BtSync.new
      @bt.add_folder '/home/vagrant'
      @bt.listening_port = 63754
      @bt.upload_limit = 0
      @bt.device_name = "precise32 - Default Instance"
      @directory = @bt.folders.first
    end
    VCR.use_cassette('Setup-Directory-Settings') do
      @directory.send('default_settings')
      @directory.add_host('192.168.1.5','45685')
    end
  end
  after(:each) do
    VCR.use_cassette('Setup-Directory-Settings') do
      @directory.send('default_settings')
    end
    VCR.use_cassette('Remove-Default-Host') do
      @directory.remove_host 0
    end
  end
  it "can view contained folders" do
    VCR.use_cassette("view-folders") do
      @folders = @directory.folders
    end
    @folders.should == []
  end
  it "can get a list of peers" do
    VCR.use_cassette("get-peers") do
      @peers = @directory.peers
    end
    @peers.should == []
  end
  it "can add and remove a known host" do
    VCR.use_cassette('add-known-host') do
      @directory.add_host('10.0.1.254', '12345')
      @hosts = @directory.known_hosts
    end
    @hosts[1].should == "10.0.1.254:12345"

    VCR.use_cassette('remove-known-host') do
      @directory.remove_host(1)
      @hosts = @directory.known_hosts
    end
    @hosts.values.should_not include '10.0.1.254:12345'
  end
  it "can check it's settings" do
    VCR.use_cassette("get-preferences") do
      @directory.use_tracker?.should == true
      @directory.use_hosts?.should == true
      @directory.search_lan?.should == true
      @directory.search_dht?.should == false
      @directory.use_relay?.should == true
      @directory.delete_to_trash?.should == true
    end
  end
  it "can change it's tracker settings" do
    VCR.use_cassette("set-preferences-tracker") do
      @directory.use_tracker = false
      @directory.use_tracker?.should == false
    end
  end
  it "can change it's hosts settings" do
    VCR.use_cassette("set-preferences-hosts") do
      @directory.use_hosts = false
      @directory.use_hosts?.should == false
    end
  end
  it "can change it's lan settings" do
    VCR.use_cassette("set-preferences-lan") do
      @directory.search_lan = false
      @directory.search_lan?.should == false
    end
  end
  it "can change it's dht settings" do
    VCR.use_cassette("set-preferences-dht") do
      @directory.search_dht = true
      @directory.search_dht?.should == true
    end
  end
  it "can change it's relay settings" do
    VCR.use_cassette("set-preferences-relay") do
      @directory.use_relay = false
      @directory.use_relay?.should == false
    end
  end
  it "can change it's delete settings" do
    VCR.use_cassette("set-preferences-delete") do
      @directory.delete_to_trash = false
      @directory.delete_to_trash?.should == false
    end
  end
end