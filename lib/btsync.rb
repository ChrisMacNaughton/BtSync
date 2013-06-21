# encoding: utf-8
require 'httparty'
lib = File.expand_path('../btsync', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'communicator'
require 'directory'

class BtSync
  include BtCommunicator
  include HTTParty
  default_params output: 'json'
  def initialize(options = {})
    @opts = setup_opts(options)
    @errors = []
    @token_cache = 0
  end

  def errors
    errors = @errors
    @errors = []
    errors
  end

  def folders
    f = get_folder_list['folders']
    folders = []
    f.each do |folder|
      folders << Directory.new(folder['name'], folder['secret'], self)
    end
    folders
  end

  def upload_limit
    get_settings['ulrate'].to_i
  end

  def download_limit
    get_settings['dlrate'].to_i
  end

  def device_name
    get_settings['devicename']
  end

  def listening_port
    get_settings['listeningport'].to_i
  end

  def upload_limit=(opt)
    change_setting 'ulrate', opt
  end

  def download_limit=(opt)
    change_setting 'dlrate', opt
  end

  def device_name=(opt)
    change_setting 'devicename', opt
  end

  def listening_port=(opt)
    change_setting 'listeningport', opt
  end

  def change_setting(type, opt)
    options = get_settings.merge!({ type => opt })

    get(path('setsettings'), query: options)
  end

  def get_speed
    s = get_folder_list['speed'].split(', ')
    {
      up: {
        speed: up(s)[0], metric: up(s)[1]
      },
      down: {
        speed: down(s)[0], metric: down(s)[1]
      }
    }
  end

  def up(s)
    s[0].split(' ')
  end

  def down(s)
    s[1].split(' ')
  end

  def remove_folder(folder_name, my_secret = nil)
    my_secret ||= secret(folder_name)
    query = { name: folder_name, secret: my_secret }
    get(path('removefolder'), query: query)
    true
  end

  def add_folder(folder_name, my_secret = nil)
    my_secret ||= generate_secret
    query = { name: folder_name, secret: my_secret }
    res = get(path('addsyncfolder'), query: query)
    unless res['error'] == 0
      @errors << res['message']
      return false
    end
    Directory.new(folder_name, my_secret, self)
  end

  def get_settings
    res = get(path('getsettings'))
    res.parsed_response['settings']
  end

  def get_os_type
    res = get(path('getostype'))
    res.parsed_response['os']
  end

  def get_version
    res = get(path('getversion'))
    res.parsed_response['version']
  end

  def check_new_version
    res = get(path('checknewversion'))
    res.parsed_response['version']
  end

  def get_dir(with_dir = '/')
    res = get(path('getdir'), query: { 'dir' => with_dir })
    res.parsed_response['folders'].map { |f| f.gsub!('//', '/') }
  end

  def secret(with_dir)
    f = folders.select { |folder| folder.name == with_dir }.first
    f.secret
  end

  private

  def setup_opts(opts)
    opt = defaults.merge!(opts.symbolize)
    opt[:uri].gsub!(%r(^(https?://){1,})i, '')
    @port =  opt[:port]
    @user = opt[:user]
    @pass = opt[:password]
    opt
  end

  def defaults
    {
      protocol: 'http',
      uri: 'localhost',
      port: '8888',
      user: 'admin',
      password: 'AdminPassword'
    }
  end

  def get_folder_list
    res = get(path('getsyncfolders'))
    @folder_list = res.parsed_response
  end
end
class Hash
  def symbolize
    r = {}
    self.each do |k, v|
      if k.is_a? String
        r[k.to_symbol] = v
      else
        r[k] = v
      end
    end
    r
  end
end