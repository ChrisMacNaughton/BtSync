# encoding: utf-8
my_testing_path = File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.expand_path(my_testing_path)

describe 'BtSync::Directory' do
  before(:each) do
    VCR.use_cassette('Setup-BtSync-Directory') do
      @bt = BtSync.new
      @bt.add_folder '/home/vagrant'
      @bt.listening_port = 63754
      @bt.upload_limit = 0
      @bt.device_name = 'precise32 - Default Instance'
      @directory = @bt.folders.first
    end
    VCR.use_cassette('Setup-Directory-Settings') do
      @directory.send('default_settings')
      @directory.add_host('192.168.1.5', '45685')
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
  it 'can view contained folders' do
    VCR.use_cassette('view-folders') do
      @folders = @directory.folders
    end
    @folders.should == []
  end
  it 'can get a list of peers' do
    VCR.use_cassette('get-peers') do
      @peers = @directory.peers
    end
    @peers.should == []
  end
  it 'can add and remove a known host' do
    VCR.use_cassette('add-known-host') do
      @directory.add_host('10.0.1.254', '12345')
      @hosts = @directory.known_hosts
    end
    @hosts.values.should include '10.0.1.254:12345'

    VCR.use_cassette('remove-known-host') do
      @directory.remove_host_by_ip('10.0.1.254')
      @hosts = @directory.known_hosts
    end
    @hosts.values.should_not include '10.0.1.254:12345'
  end
  it "can check it's settings" do
    VCR.use_cassette('get-preferences') do
      @directory.use_tracker?.should be == true
      @directory.use_hosts?.should be == true
      @directory.search_lan?.should be == true
      @directory.search_dht?.should be == false
      @directory.use_relay?.should be == true
      @directory.delete_to_trash?.should be == true
    end
  end
  it "can change it's tracker settings" do
    VCR.use_cassette('set-preferences-tracker') do
      @directory.use_tracker = false
      @directory.use_tracker?.should be == false
    end
  end
  it "can change it's hosts settings" do
    VCR.use_cassette('set-preferences-hosts') do
      @directory.use_hosts = false
      @directory.use_hosts?.should be == false
    end
  end
  it "can change it's lan settings" do
    VCR.use_cassette('set-preferences-lan') do
      @directory.search_lan = false
      @directory.search_lan?.should be == false
    end
  end
  it "can change it's dht settings" do
    VCR.use_cassette('set-preferences-dht') do
      @directory.search_dht = true
      @directory.search_dht?.should be == true
    end
  end
  it "can change it's relay settings" do
    VCR.use_cassette('set-preferences-relay') do
      @directory.use_relay = false
      @directory.use_relay?.should be == false
    end
  end
  it "can change it's delete settings" do
    VCR.use_cassette('set-preferences-delete') do
      @directory.delete_to_trash = false
      @directory.delete_to_trash?.should be == false
    end
  end
  it "can change its secret" do
    @secret = @directory.secret
    VCR.use_cassette('change secret empty') do
      @directory.update_secret
      @directory.secret.should_not be == @secret
    end

    VCR.use_cassette('change secret custom') do
      new_secret = @directory.generate_secret
      @directory.update_secret(new_secret)
      @directory.secret.should_not be == @secret
      @directory.secret.should be == new_secret
    end
    VCR.use_cassette('reset secret') do
      @directory.update_secret(@secret)
    end
    @directory.secret.should be == @secret
  end
end