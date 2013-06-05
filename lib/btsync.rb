require 'httparty'

class BtSync
  include HTTParty
  default_params :output => 'json'
  debug_output
  def initialize uri=nil, port=nil
    @uri = uri
    @port = port
    @errors = []
    @token_cache = 0
  end
  def errors
    errors = @errors
    @errors = []
    errors
  end
  def get_folders
    get_folder_list["folders"]
  end
  def get_speed
    s = get_folder_list["speed"].split(", ")
    up = s[0].split(" ")
    down = s[1].split(" ")
    {:up => up[0], :down => down[0], :metric => up[1]}
  end
  def remove_folder folder_name, my_secret = nil
    my_secret ||= secret(folder_name)
    res = self.class.get(path('removefolder'), :query => { :name => folder_name, :secret => my_secret}, :headers => {"Cookie" => cookies})
    token(true)
    true
  end
  def add_folder folder_name, my_secret = nil
    my_secret ||= generate_secret
    res = self.class.get(path('addsyncfolder'), :query => { :name => folder_name, :secret => my_secret}, :headers => {"Cookie" => cookies})
    unless res["error"] == 0
      @errors << res["message"]
      return false
    end
    token(true)
    true
  end
  def update_secret with_dir, new_secret = nil, my_secret = nil
    my_secret ||= secret(with_dir)
    new_secret ||= generate_secret
    self.class.get(path('updatesecret'), :query => { :name => with_dir, :secret => my_secret, :newsecret => new_secret}, :headers => {"Cookie" => cookies})
    true
  end
  def use_tracker with_dir, opt = true
    res = self.class.get(path('setfolderpref'), query: make_opts(with_dir, 'usetracker', opt), :headers => {"Cookie" => cookies })
    true
  end
  def use_tracker? with_dir
    bool(get_folder_preferences(with_dir)["usetracker"])
  end
  def use_hosts with_dir, opt = false
    res = self.class.get(path('setfolderpref'), query: make_opts(with_dir, 'usehosts', opt), :headers => {"Cookie" => cookies })
    true
  end
  def use_hosts? with_dir
    bool(get_folder_preferences(with_dir)["usehosts"])
  end
  def search_lan with_dir, opt = true
    res = self.class.get(path('setfolderpref'), query: make_opts(with_dir, 'searchlan', opt), :headers => {"Cookie" => cookies })
    true
  end
  def search_lan? with_dir
    bool(get_folder_preferences(with_dir)["searchlan"])
  end
  def search_dht with_dir, opt = false
    res = self.class.get(path('setfolderpref'), query: make_opts(with_dir, 'searchdht', opt), :headers => {"Cookie" => cookies })
    true
  end
  def search_dht? with_dir
    bool(get_folder_preferences(with_dir)["searchdht"])
  end
  def use_relay with_dir, opt = true
    res = self.class.get(path('setfolderpref'), query: make_opts(with_dir, 'relay', opt), :headers => {"Cookie" => cookies })
    true
  end
  def use_relay? with_dir
    bool(get_folder_preferences(with_dir)["relay"])
  end
  def delete_to_trash with_dir, opt = true
    res = self.class.get(path('setfolderpref'), query: make_opts(with_dir, 'deletetotrash', opt), :headers => {"Cookie" => cookies })
    true
  end
  def delete_to_trash? with_dir
    bool(get_folder_preferences(with_dir)["deletetotrash"])
  end
  def is_writable? with_dir
    bool(get_folder_preferences(with_dir)["iswritable"])
  end
  def generate_secret
    res = self.class.get(path('generatesecret'), :headers => {"Cookie" => cookies })
    res.parsed_response["secret"]
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
  def get_folder_preferences folder_name, my_secret = nil
    my_secret ||= secret(folder_name)
    res = self.class.get(path('getfolderpref'), :query => { :name => folder_name, :secret => my_secret}, :headers => {"Cookie" => cookies})
    res.parsed_response["folderpref"]
  end
  def get_dir with_dir
    res = self.class.get(path('getdir'), :query => {:dir => with_dir}, :headers => {"Cookie" => cookies })
    res.parsed_response["folders"]
  end
  def get_known_hosts with_dir, my_secret = nil
    my_secret ||= secret(with_dir)
    res = self.class.get(path('getknownhosts'), :query => {:name => with_dir, :secret => my_secret}, :headers => {"Cookie" => cookies })
    res["hosts"]
  end
  def secret with_dir
    f = get_folders.select{|folder| folder["name"] == with_dir}.first
    f["secret"]
  end
  def get_read_only_secret with_dir, my_secret = nil
    my_secret ||= secret(with_dir)
    get_folder_preferences(with_dir, my_secret)["readonlysecret"]
  end
  private
  def make_opts with_dir, name, opt
    opts = get_folder_preferences(with_dir)
    opts[name] = bool_to_i(opt)
    opts.delete('readonlysecret')
    opts.merge!({:name => with_dir, :secret => secret(with_dir)})
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
  def get_folder_list
    res = self.class.get(path('getsyncfolders'), :headers => {"Cookie" => cookies })
    @folder_list = res.parsed_response
  end

  def port
    @port ||= '8888'
  end
  def uri
    @uri ||= "http://localhost"
  end
  def token force = false
    time = DateTime.now.strftime("%s").to_i
    if time > @token_cache + 600 || force
      @token = request_token(force).gsub('</div></html>', '').gsub("<html><div id='token' style='display:none;'>", '')
      @token_cache = time
    end
    @cookies = nil if force
    @token
  end
  def cookies
    @cookies ||= request_token.headers["set-cookie"].split("; ")[0]
  end
  def request_token force = false
    if @request_token.nil? || force
      @request_token = self.class.get("#{uri}:#{port}/gui/token.html", :query => {:output => :text})
    else
      @request_token
    end
  end
  def path action_name
    "#{uri}:#{port}/gui/?token=#{token}&action=#{action_name}"
  end
end
