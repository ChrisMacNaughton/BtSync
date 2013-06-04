require "btsync/version"
require 'httparty'

class Btsync
  include 'httparty'
  def initialize uri, port
    @uri = uri
    @port = port
  end
  def generate_secret
    action 'generatesecret'
  end
  private
  def secret
    @secret ||= self.get(path + 'token.html?t=' + DateTime.now.strftime('%s'))
  end
  def path
    "#{uri}:#{port}/gui"
  end
  def action action_name
    self.get(path, :query => {:token => secret, :action => action_name})
  end
end
