module BtCommunicator
  include HTTParty
  disable_rails_query_string_format
  default_params :output => 'json'
  def generate_secret
    res = get(path('generatesecret'))
    res.parsed_response["secret"]
  end
  def port
    @opts[:port]
  end
  def uri
    @opts[:uri]
  end
  def protocol
    @opts[:protocol]
  end
  def user
    @opts[:user]
  end
  def password
    @opts[:password]
  end
  def communication_options
    @opts
  end
  def auth
    {username: user, password: password}
  end
  def token force = false
    @token_cache ||= 0
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
  def root_url
    "#{starter}#{uri}:#{port}/"
  end

  def get path, opts = {}
    opts = {headers: {"Cookie" => cookies}, query: {}, basic_auth: auth}.merge(opts)
    self.class.get(path, opts)
  end

  def request_token force = false
    @last_request ||= 0
    t = DateTime.now.strftime('%s').to_i
    if @request_token.nil? || force || (@last_request + 600) < t
      @last_request = t
      @request_token = self.class.get("#{root_url}gui/token.html", basic_auth: auth)
    else
      @request_token
    end
  end
  def starter
    "#{protocol}://"
  end
  def path action_name
    "#{root_url}gui/?token=#{token}&action=#{action_name}"
  end
end