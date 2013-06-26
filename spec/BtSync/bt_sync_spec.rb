# encoding: utf-8
my_testing_path = File.join(File.dirname(__FILE__), '..', 'spec_helper')
require File.expand_path(my_testing_path)
require 'btsync'
describe 'BtSync' do
  before(:each) do
    VCR.use_cassette('Setup-BtSync') do
      @bt = BtSync.new
      @bt.folders.each { |f| @bt.remove_folder f.name }
      @bt.add_folder '/home/vagrant'
      @bt.listening_port = 63754
      @bt.upload_limit = 0
      @bt.device_name = 'precise32 - Default Instance'
    end
  end
  it 'can check for errors' do
    @bt.errors.should be == []
  end
  it 'can view folders on a system' do
    VCR.use_cassette('get dir') do
    @bt.get_dir.should include '/bin'
    @bt.get_dir.should include '/etc'
    @bt.get_dir.should include '/home'
    end
  end
  it 'can get the version' do
    VCR.use_cassette('get version') do
      @bt.get_version.should be >= 16_842_767
    end
  end
  it 'can view a folder list' do
    VCR.use_cassette('get-folders') do
      @folder = @bt.folders.first
    end
    @folder.name.should be == '/home/vagrant'
  end
  it 'can view settings' do
    VCR.use_cassette('get-settings') do
      @settings = @bt.get_settings
    end
    @settings['devicename'].should be == 'precise32 - Default Instance'
    @settings['listeningport'].should be == 63754
  end
  it 'can get listening port' do
    VCR.use_cassette('get-settings') do
      @bt.listening_port.should be == 63754
    end
  end
  it 'can get upload limit' do
    VCR.use_cassette('get-settings') do
      @bt.upload_limit.should be == 0
    end
  end
  it 'can get download limit' do
    VCR.use_cassette('get-settings') do
      @bt.download_limit.should be == 0
    end
  end
  it 'can get device name' do
    VCR.use_cassette('get-settings') do
      @bt.device_name.should be == 'precise32 - Default Instance'
    end
  end
  it 'can change the device_name' do
    VCR.use_cassette('change_name') do
      @bt.device_name = 'IceyEC-Virtual2'
      @bt.device_name.should be == 'IceyEC-Virtual2'
    end
    VCR.use_cassette('reset_device_name') do
      @bt.device_name = 'precise32 - Default Instance'
      @bt.device_name.should be == 'precise32 - Default Instance'
    end
  end
  it 'can change the upload limit' do
    VCR.use_cassette('change_upload_limit') do
      @bt.upload_limit = 1000
      @bt.upload_limit.should be == 1000
    end
    VCR.use_cassette('reset_upload_limit') do
      @bt.upload_limit = 0
      @bt.upload_limit.should be == 0
    end
  end
  it 'can change the download limit' do
    VCR.use_cassette('change_download_limit') do
      @bt.download_limit = 1000
      @bt.download_limit.should be == 1000
    end
    VCR.use_cassette('reset_download_limit') do
      @bt.download_limit = 0
      @bt.download_limit.should be == 0
    end
  end
  it 'can change the listening_port' do
    VCR.use_cassette('change_listening_port') do
      @bt.listening_port = 12345
      @bt.listening_port.should be == 12345
    end
    VCR.use_cassette('reset_listening_port') do
      @bt.listening_port = 63754
      @bt.listening_port.should be == 63754
    end
  end
  it 'can check the OS' do
    VCR.use_cassette('get-os-type') do
      @os = @bt.get_os_type
    end
    @os.should be == 'linux'
  end
  it 'can add and delete a folder' do
    VCR.use_cassette('add-folder') do
      @bt.add_folder '/tmp'
    end
    VCR.use_cassette('add-folder-list') do
      folders = @bt.folders
      folders.count.should be == 2
      folder = folders.last
      folder.name.should be == '/tmp'
    end
    VCR.use_cassette('remove-folder') do
      @bt.remove_folder '/tmp'
    end
    VCR.use_cassette('remove-folder-list') do
      folders = @bt.folders
      folders.count.should be == 1
      folder = folders.last
      folder.name.should be == '/home/vagrant'
    end
  end
  it 'can check speeds' do
    VCR.use_cassette('check speeds', allow_playback_repeats: true) do
      @bt.speed('up').should be == {speed: 0.0, metric: 'kB/s'}
    end
    VCR.use_cassette('check speeds', allow_playback_repeats: true) do
      @bt.speed('down').should be == {speed: 0.0, metric: 'kB/s'}
    end
    VCR.use_cassette('check speeds', allow_playback_repeats: true) do
      @bt.get_speed.should be == {up: {speed: 0.0, metric: 'kB/s'}, down: {speed: 0.0, metric: 'kB/s'}}
    end
  end
  it 'can check for new versions' do
    VCR.use_cassette('check for new version') do
      res = @bt.check_new_version
      res["url"].should be == ""
      res["version"].should be == 0
    end
  end
  it 'can symbolize a hash -_-' do
    @bt.send('symbolize', {'test' => 'value'}).should be == {test: 'value'}
    @bt.send('symbolize', {test: 'value'}).should be == {test: 'value'}
  end
end