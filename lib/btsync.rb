require 'httparty'

class BtSync
  include HTTParty
  default_params :output => 'json'
  #debug_output
  def initialize uri=nil, port=nil
    @uri = uri
    @port = port
    @token_cache = 0
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
  def remove_folder folder_name
    res = self.class.get(path('removefolder'), :query => { :name => folder_name, :secret => secret(folder_name)}, :headers => {"Cookie" => cookies})
    token(true)
    true
  end
  def add_folder folder_name
    res = self.class.get(path('addsyncfolder'), :query => { :name => folder_name, :secret => generate_secret}, :headers => {"Cookie" => cookies})
    token(true)
    true
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
  def get_folder_preferences folder_name
    res = self.class.get(path('getfolderpref'), :query => { :name => folder_name, :secret => secret(folder_name)}, :headers => {"Cookie" => cookies})
    res.parsed_response["folderpref"]
  end
  def get_dir with_dir
    res = self.class.get(path('getdir'), :query => {:dir => with_dir}, :headers => {"Cookie" => cookies })
    res.parsed_response["folders"]
  end
  private
  def secret folder_name
    f = get_folders.select{|folder| folder["name"] == folder_name}.first
    f["secret"]
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
      @token = request_token.gsub('</div></html>', '').gsub("<html><div id='token' style='display:none;'>", '')
      @token_cache = time
    end
    @cookies = nil if force
    @token
  end
  def cookies
    @cookies ||= request_token.headers["set-cookie"].split("; ")[0]
  end
  def request_token
    @request_token ||= self.class.get("#{uri}:#{port}/gui/token.html", :query => {:output => :text})
  end
  def path action_name
    "#{uri}:#{port}/gui/?token=#{token}&action=#{action_name}"
  end
end
