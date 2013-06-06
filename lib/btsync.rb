require 'httparty'
lib = File.expand_path('../btsync', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'communicator'

class BtSync
  include BtCommunicator
  include HTTParty
  default_params :output => 'json'
  def initialize options = {}
    @opts = options.symbolize
    @opts.merge!({:uri => "http://localhost", :port => "8888", :user => "", :password => ""})
    @uri = @opts[:uri]
    @port =  @opts[:port]
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

  class Directory
    include HTTParty
    include BtCommunicator
    default_params :output => 'json'

    attr_reader :secret, :name

    def initialize name, secret, btsync
      @name = name
      @secret = secret

      @uri = btsync.uri
      @port = btsync.port

      find_or_create

      @errors = []
    end

    def destroy
      self.class.get(path('removefolder'), :query => { :name => name, :secret => secret}, :headers => {"Cookie" => cookies})
      self.instance_variables.each{|v| v = nil}
    end
    def update_secret new_secret = nil
      new_secret ||= generate_secret
      res = self.class.get(path('updatesecret'), :query => { :name => @name, :secret =>  @secret, :newsecret => new_secret}, :headers => {"Cookie" => cookies})
      if res.parsed_response != "{}" && res.parsed_response != '\r\ninvalid request'
        @secret = new_secret
        true
      else
        @errors << res.parsed_response
        false
      end
    end
    def folders
      res = self.class.get(path('getdir'), :query => {:dir => @name}, :headers => {"Cookie" => cookies })
      res.parsed_response["folders"]
    end
    def peers
      res = self.class.get(path('getsyncfolders'), :headers => {"Cookie" => cookies })
      f = res.parsed_response["folders"].select{|f| f["name"] == name}.first
      f["peers"]
    end
    def known_hosts
      res = self.class.get(path('getknownhosts'), :query => {:name => name, :secret => secret}, :headers => {"Cookie" => cookies })
      res["hosts"]
    end
    def use_tracker=(opt)
      res = self.class.get(path('setfolderpref'), query: make_opts('usetracker', opt), :headers => {"Cookie" => cookies })
      true
    end
    def use_tracker?
      bool(preferences["usetracker"])
    end
    def use_hosts=(opt)
      res = self.class.get(path('setfolderpref'), query: make_opts('usehosts', opt), :headers => {"Cookie" => cookies })
      true
    end
    def use_hosts?
      bool(preferences["usehosts"])
    end
    def search_lan=(opt)
      res = self.class.get(path('setfolderpref'), query: make_opts('searchlan', opt), :headers => {"Cookie" => cookies })
      true
    end
    def search_lan?
      bool(preferences["searchlan"])
    end
    def search_dht=(opt)
      res = self.class.get(path('setfolderpref'), query: make_opts('searchdht', opt), :headers => {"Cookie" => cookies })
      true
    end
    def search_dht?
      bool(preferences["searchdht"])
    end
    def use_relay=(opt)
      res = self.class.get(path('setfolderpref'), query: make_opts('relay', opt), :headers => {"Cookie" => cookies })
      true
    end
    def use_relay?
      bool(preferences["relay"])
    end
    def delete_to_trash=(opt)
      res = self.class.get(path('setfolderpref'), query: make_opts('deletetotrash', opt), :headers => {"Cookie" => cookies })
      true
    end
    def delete_to_trash?
      bool(preferences["deletetotrash"])
    end
    def is_writable? with_dir
      bool(preferences["iswritable"])
    end
    def preferences
      res = self.class.get(path('getfolderpref'), :query => { :name => @name, :secret => @secret}, :headers => {"Cookie" => cookies})
      res.parsed_response["folderpref"]
    end
    def read_only_secret
      preferences["readonlysecret"]
    end
    private
    def make_opts name, opt
     opts = preferences
     opts[name] = bool_to_i(opt)
     opts.delete('readonlysecret')
     opts.merge!({:name => @name, :secret => @secret})
    end
    def bool i
      if i == 0
        false
      elsif i == 1
        true
      else
        i
      end
    end
    def bool_to_i bool
      if bool
        1
      else
        0
      end
    end
    def find_or_create
      res = self.class.get(path('getsyncfolders'), :headers => {"Cookie" => cookies })
      folder_list = res.parsed_response["folders"]
      if folder_list.map{|f| f["name"]}.include? name
        true
      else
        res = self.class.get(path('addsyncfolder'), :query => { :name => name, :secret => secret}, :headers => {"Cookie" => cookies})
      end
    end
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