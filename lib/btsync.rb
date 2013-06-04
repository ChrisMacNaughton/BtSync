require 'httparty'
require 'nokogiri'
require 'json'

class Btsync
  include HTTParty
  def initialize uri=nil, port=nil
    @cache = {
      :folder => 0,
      :secret => 0,
      :settings => 0,
      :os_type => 0,
      :new_version => 0
    }
    @uri = uri
    @port = port
    secret
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
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:settings] + 600
      res = self.class.get(path('getsettings'), :query => {:output => "json"}, :headers => {"Cookie" => cookies })
      @settings = res.parsed_response["settings"]
      @cache[:settings] = time
    end
    @settings
  end
  def get_os_type
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:os_type] + 600
      res = self.class.get(path('getostype'), :query => {:output => "json"}, :headers => {"Cookie" => cookies })
      @os_type = res.parsed_response["os"]
      @cache[:os_type] = time
    end
    @os_type
  end
  def get_version
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:version] + 600
      res = self.class.get(path('getversion'), :query => {:output => "json"}, :headers => {"Cookie" => cookies })
      @version = res.parsed_response
      @cache[:version] = time
    end
    @version
  end
  def check_new_version
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:new_version] + 600
      res = self.class.get(path('checknewversion'), :query => {:output => "json"}, :headers => {"Cookie" => cookies })
      @new_version = res.parsed_response["version"]
      @cache[:new_version] = time
    end
    @new_version
  end
  def get_dir with_dir
    res = self.class.get(path('getdir'), :query => {:dir => with_dir, :output => "json"}, :headers => {"Cookie" => cookies })
    res.parsed_response["folders"]
  end
  private
  def get_folder_list
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:folder] + 600
      res = self.class.get(path('getsyncfolders'), :query => {:output => "json"}, :headers => {"Cookie" => cookies })
      @folder_list = res.parsed_response
      @cache[:folder] = time
    end
    @folder_list
  end

  def port
    @port ||= '8888'
  end
  def uri
    @uri ||= "http://localhost"
  end
  def secret
    time = DateTime.now.strftime("%s").to_i
    if time > @cache[:secret] + 600
      @secret = Nokogiri::HTML(request_token).search('#token').text
      @cache[:secret] = time
    end
    @secret
  end
  def cookies
    @cookies ||= request_token.headers["set-cookie"].split("; ")[0]
  end
  def request_token
    @request_token ||= self.class.get("#{uri}:#{port}/gui/token.html?t=" + DateTime.now.strftime('%s'))
  end
  def path action_name
    "#{uri}:#{port}/gui/?token=#{secret}&action=#{action_name}"
  end
end
