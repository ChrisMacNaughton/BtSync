require 'httparty'

class BtSync
  include HTTParty
  default_params :output => 'json'
  def initialize uri=nil, port=nil
    @cache = {
      :folder => 0,
      :secret => 0,
      :settings => 0,
      :os_type => 0,
      :version => 0,
      :new_version => 0
    }
    @uri = uri
    @port = port
    token
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

  def get_settings
    res = self.class.get(path('getsettings'), :headers => {"Cookie" => cookies })
    @settings = res.parsed_response["settings"]
  end
  def get_os_type
    res = self.class.get(path('getostype'), :headers => {"Cookie" => cookies })
    @os_type = res.parsed_response["os"]
  end
  def get_version
    res = self.class.get(path('getversion'), :headers => {"Cookie" => cookies })
    @version = res.parsed_response["version"]
  end
  def check_new_version
    res = self.class.get(path('checknewversion'), :headers => {"Cookie" => cookies })
    @new_version = res.parsed_response["version"]
  end
  def get_dir with_dir
    res = self.class.get(path('getdir'), :query => {:dir => with_dir}, :headers => {"Cookie" => cookies })
    res.parsed_response["folders"]
  end
  private
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
  def token
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:secret] + 600
      @token = request_token.gsub('</div></html>', '').gsub("<html><div id='token' style='display:none;'>", '')
      @cache[:secret] = time
    end
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
