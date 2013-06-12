class BtSync
  class Directory
    include HTTParty
    include BtCommunicator
    default_params :output => 'json'
    attr_reader :secret, :name

    def initialize name, secret, btsync
      @name = name
      @secret = secret

      @opts = btsync.communication_options

      find_or_create

      @errors = []
    end

    def destroy
      get(path('removefolder'), :query => { :name => name, :secret => secret} )
      self.instance_variables.each{|v| v = nil}
    end
    def update_secret new_secret = nil
      new_secret ||= generate_secret
      res = get(path('updatesecret'), :query => { :name => @name, :secret =>  @secret, :newsecret => new_secret} )
      if res.parsed_response != "{}" && res.parsed_response != '\r\ninvalid request'
        @secret = new_secret
        true
      else
        @errors << res.parsed_response
        false
      end
    end
    def folders
      res = get(path('getdir'), :query => {:dir => @name})
      res.parsed_response["folders"]
    end
    def peers
      res = get(path('getsyncfolders') )
      f = res.parsed_response["folders"].select{|f| f["name"] == name}.first
      f["peers"]
    end
    def known_hosts
      res = get(path('getknownhosts'), :query => {:name => name, :secret => secret})
      hosts = {}
      res["hosts"].map{|h| hosts[h["index"]] = h["peer"]}
      hosts
    end
    def add_host host, port
      res = get(path('addknownhosts'), :query =>{:name => name, :secret => secret, :addr =>host, :port => port} )
      true
    end
    def remove_host index
      res = get(path('removeknownhosts'), :query =>{:name => name, :secret => secret, :index => index} )
      if res.parsed_response != {}
        res.parsed_response
      else
        true
      end
    end
    def remove_host_by_ip ip, port = nil
      @hosts = known_hosts
    end
    def use_tracker=(opt)
      set_pref('usetracker', opt)
    end
    def use_tracker?
      bool(preferences["usetracker"])
    end
    def use_hosts=(opt)
      set_pref('usehosts', opt)
    end
    def use_hosts?
      bool(preferences["usehosts"])
    end
    def search_lan=(opt)
      set_pref('searchlan', opt)
    end
    def search_lan?
      bool(preferences["searchlan"])
    end
    def search_dht=(opt)
      set_pref('searchdht', opt)
    end
    def search_dht?
      bool(preferences["searchdht"])
    end
    def use_relay=(opt)
      set_pref('relay', opt)
    end
    def use_relay?
      bool(preferences["relay"])
    end
    def delete_to_trash=(opt)
      set_pref('deletetotrash', opt)
    end
    def delete_to_trash?
      bool(preferences["deletetotrash"])
    end
    def is_writable? with_dir
      bool(preferences["iswritable"])
    end
    def preferences
      res = get(path('getfolderpref'), :query => { :name => @name, :secret => @secret})
      res.parsed_response["folderpref"]
    end
    def read_only_secret
      preferences["readonlysecret"]
    end
    private
    def set_pref pref, opt
      res = get(path('setfolderpref'), :query => make_opts(pref, opt) )
      true
    end
    def default_settings
      opts = {
        'name'=>@name,
        'secret'=>@secret,
        'relay' => 1,
        'usetracker' => 1,
        'searchlan' => 1,
        'searchdht' => 0,
        'deletetotrash' => 1,
        'usehosts' => 1
      }
      get(path('setfolderpref'), :query => opts )
    end
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
      res = get(path('getsyncfolders'))
      folder_list = res.parsed_response["folders"]
      if folder_list.map{|f| f["name"]}.include? name
        true
      else
        res = get(path('addsyncfolder'), :query => { :name => name, :secret => secret})
      end
    end
  end
end