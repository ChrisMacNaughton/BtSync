class BtSync
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
      res = self.class.get(path('setfolderpref'), :query => make_opts('usetracker', opt), :headers => {"Cookie" => cookies })
      @preferences = nil
      true
    end
    def use_tracker?
      bool(preferences["usetracker"])
    end
    def use_hosts=(opt)
      res = self.class.get(path('setfolderpref'), :query => make_opts('usehosts', opt), :headers => {"Cookie" => cookies })
      @preferences = nil
      true
    end
    def use_hosts?
      bool(preferences["usehosts"])
    end
    def search_lan=(opt)
      res = self.class.get(path('setfolderpref'), :query => make_opts('searchlan', opt), :headers => {"Cookie" => cookies })
      @preferences = nil
      true
    end
    def search_lan?
      bool(preferences["searchlan"])
    end
    def search_dht=(opt)
      res = self.class.get(path('setfolderpref'), :query => make_opts('searchdht', opt), :headers => {"Cookie" => cookies })
      @preferences = nil
      true
    end
    def search_dht?
      bool(preferences["searchdht"])
    end
    def use_relay=(opt)
      res = self.class.get(path('setfolderpref'), :query => make_opts('relay', opt), :headers => {"Cookie" => cookies })
      @preferences = nil
      true
    end
    def use_relay?
      bool(preferences["relay"])
    end
    def delete_to_trash=(opt)
      res = self.class.get(path('setfolderpref'), :query => make_opts('deletetotrash', opt), :headers => {"Cookie" => cookies })
      @preferences = nil
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
      self.class.get(path('setfolderpref'), :query => opts, :headers => {"Cookie" => cookies })
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