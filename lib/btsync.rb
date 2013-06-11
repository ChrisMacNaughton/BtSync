require 'httparty'
lib = File.expand_path('../btsync', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'communicator'
require 'directory'

class BtSync
  include BtCommunicator
  include HTTParty
  default_params :output => 'json'
  def initialize options = {}
    @opts = {
      :protocol => "http",
      :uri => "localhost",
      :port => "8888",
      :user => "",
      :password => ""}
    @opts.merge!(options.symbolize)
    @opts[:uri].gsub!(/^(https?:\/\/){1,}/i, '')
    @port =  @opts[:port]
    @user = @opts[:user]
    @pass = @opts[:password]
    @errors = []
    @token_cache = 0
  end
  def errors
    errors = @errors
    @errors = []
    errors
  end
  def folders
    f = get_folder_list["folders"]
    folders = []
    f.each do |folder|
      folders << Directory.new(folder["name"], folder["secret"], self)
    end
    folders
  end
  def upload_limit
    get_settings["ulrate"].to_i
  end
  def download_limit
    get_settings["dlrate"].to_i
  end
  def device_name
    get_settings["devicename"]
  end
  def listening_port
    get_settings["listeningport"].to_i
  end
  def upload_limit= opt
    change_setting "ulrate", opt
  end
  def download_limit= opt
    change_setting "dlrate", opt
  end
  def device_name= opt
    change_setting "devicename", opt
  end
  def listening_port= opt
    change_setting "listeningport", opt
  end
  def change_setting type, opt
    options = get_settings.merge!({type => opt})

    res = self.class.get(path('setsettings'), :query => options, :headers => {"Cookie" => cookies })
  end
  def get_speed
    s = get_folder_list["speed"].split(", ")
    up = s[0].split(" ")
    down = s[1].split(" ")
    {:up => {:speed => up[0], :metric => up[1]}, :down => {:speed => down[0], :metric => down[1]}}
  end
  def remove_folder folder_name, my_secret = nil
    my_secret ||= secret(folder_name)
    res = self.class.get(path('removefolder'), :query => { :name => folder_name, :secret => my_secret}, :headers => {"Cookie" => cookies})
    true
  end
  def add_folder folder_name, my_secret = nil
    my_secret ||= generate_secret
    res = self.class.get(path('addsyncfolder'), :query => { :name => folder_name, :secret => my_secret}, :headers => {"Cookie" => cookies})
    unless res["error"] == 0
      @errors << res["message"]
      return false
    end
    Directory.new(folder_name, my_secret, self)
  end

  def get_settings
    res = self.class.get(path('getsettings'), :headers => {"Cookie" => cookies })
    res.parsed_response["settings"]
  end
  def get_os_type
    res = self.class.get(path('getostype'), :headers => {"Cookie" => cookies })
    res.parsed_response["os"]
  end
  def get_version
    res = self.class.get(path('getversion'), :headers => {"Cookie" => cookies })
    res.parsed_response["version"]
  end
  def check_new_version
    res = self.class.get(path('checknewversion'), :headers => {"Cookie" => cookies })
    res.parsed_response["version"]
  end

  def get_dir with_dir
    res = self.class.get(path('getdir'), :query => {:dir => with_dir}, :headers => {"Cookie" => cookies })
    res.parsed_response["folders"]
  end

  def secret with_dir
    f = folders.select{|folder| folder.name == with_dir}.first
    f.secret
  end
  private

  def get_folder_list
    res = self.class.get(path('getsyncfolders'), :headers => {"Cookie" => cookies })
    @folder_list = res.parsed_response
  end
end
class Hash
  def symbolize
    r = {}
    self.each do |k,v|
      if k.is_a? String
        r[k.to_symbol] = v
      else
        r[k] = v
      end
    end
    r
  end
end