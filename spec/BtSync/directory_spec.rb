require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe 'BtSync::Directory' do
  before(:each) do
    VCR.use_cassette("Setup-BtSync-Directory") do
      @bt = BtSync.new
      @directory = BtSync::Directory.new(
        '/home/chris/Documents',
        '6PX74LIR2RA2FF2W3DC25MG2CF6SQDSJ',
        @bt)
    end
    VCR.use_cassette('Setup-Directory-Settings') do
      @directory.send('default_settings')
    end
  end
  after(:each) do
    VCR.use_cassette('Setup-Directory-Settings') do
      @directory.send('default_settings')
    end
  end
  it "can view contained folders" do
    VCR.use_cassette("view-folders") do
      @folders = @directory.folders
    end
    @folders.first.should == "/home/chris/Documents/test"
  end
  it "can get a list of peers" do
    VCR.use_cassette("get-peers") do
      @peers = @directory.peers
    end
    @peers.first["name"].should == "IceyEC Portable"
  end
  it "can get see known hosts" do
    VCR.use_cassette("get-known-hosts") do
      @hosts = @directory.known_hosts
    end
    @hosts.first["peer"].should == "192.168.1.5:45685"
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