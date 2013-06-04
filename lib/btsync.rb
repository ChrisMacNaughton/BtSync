require 'httparty'
require 'nokogiri'

class Btsync
  include HTTParty

  def initialize uri=nil, port=nil
    @uri = uri
    @port = port
  end

  def port
    @port ||= '8888'
  end
  def uri
    @uri ||= "http://localhost"
  end
  def secret
    @secret ||= Nokogiri::HTML(self.class.get(path + 'token.html?t=' + DateTime.now.strftime('%s'))).search('#token').text
  end
  def path
    "#{uri}:#{port}/gui/"
  end
  def action action_name
    self.class.get(path, :query => {:token => secret, :action => action_name})
  end
end
