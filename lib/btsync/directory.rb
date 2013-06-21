# encoding: utf-8
class BtSync
  class Directory
    include HTTParty
    include BtCommunicator
    default_params output: 'json'
    attr_reader :secret, :name, :errors

    def initialize(name, secret, btsync)
      @name = name
      @secret = secret

      @opts = btsync.opts

      find_or_create

      @errors = []
    end

    def destroy
      get(path('removefolder'), query: { name: name, secret: secret })
      self.instance_variables.each { |v| v = nil }
    end

    def update_secret(new_secret = generate_secret)
      query = secret_params(new_secret)
      res = get(path('updatesecret'), query: query)
      p = res.parsed_response
      if p != {} && p != '\r\ninvalid request'
        @secret = new_secret
        true
      else
        if p == {}
          @errors << "Invalid Secret"
        else
          @errors << res.parsed_response
        end
        false
      end
    end

    def folders
      res = get(path('getdir'), query: { dir: @name })
      res.parsed_response['folders']
    end

    def peers
      res = get(path('getsyncfolders'))
      r = res.parsed_response['folders'].select { |f| f['name'] == name }.first
      r['peers']
    end

    def known_hosts
      query = { name: name, secret: secret }
      res = get(path('getknownhosts'), query: query)
      hosts = {}
      res['hosts'].map { |h| hosts[h['index']] = h['peer'] }
      hosts
    end

    def add_host(host, port)
      query = { name: name, secret: secret, addr: host, port: port }
      get(path('addknownhosts'), query: query)
      true
    end

    def remove_host(index)
      query = { name: name, secret: secret, index: index }
      res = get(path('removeknownhosts'), query: query)
      if res.parsed_response != {}
        res.parsed_response
      else
        true
      end
    end

    def remove_host_by_ip(ip, port = nil)
      known_hosts.each do |id, host|
        host = host.split(':')
        if ip == host[0]
          next if port != host[1] unless port.nil?

          remove_host(id)
        end
      end
    end

    def use_tracker=(opt)
      set_pref('usetracker', opt)
    end

    def use_tracker?
      bool(preferences['usetracker'])
    end

    def use_hosts=(opt)
      set_pref('usehosts', opt)
    end

    def use_hosts?
      bool(preferences['usehosts'])
    end

    def search_lan=(opt)
      set_pref('searchlan', opt)
    end

    def search_lan?
      bool(preferences['searchlan'])
    end

    def search_dht=(opt)
      set_pref('searchdht', opt)
    end

    def search_dht?
      bool(preferences['searchdht'])
    end

    def use_relay=(opt)
      set_pref('relay', opt)
    end

    def use_relay?
      bool(preferences['relay'])
    end

    def delete_to_trash=(opt)
      set_pref('deletetotrash', opt)
    end

    def delete_to_trash?
      bool(preferences['deletetotrash'])
    end

    def is_writable?
      bool(preferences['iswritable'])
    end

    def preferences
      res = get(path('getfolderpref'), query: { name: @name, secret: @secret })
      res.parsed_response['folderpref']
    end

    def read_only_secret
      preferences['readonlysecret']
    end

    private

    def set_pref(pref, opt)
      get(path('setfolderpref'), query: make_opts(pref, opt))
      true
    end

    def default_settings
      get(path('setfolderpref'), query: defaults)
    end

    def defaults
      {
        'name' => @name,
        'secret' => @secret,
        'relay' => 1,
        'usetracker' => 1,
        'searchlan' => 1,
        'searchdht' => 0,
        'deletetotrash' => 1,
        'usehosts' => 1
      }
    end

    def make_opts(name, opt)
     opts = preferences
     opts[name] = bool_to_i(opt)
     opts.delete('readonlysecret')
     opts.merge!({ name: @name, secret: @secret })
    end

    def secret_params(s)
      {
        name: @name,
        secret: @secret,
        newsecret: s
      }
    end

    def bool(i)
      i = i.to_i
      if i == 0
        false
      else
        true
      end
    end

    def bool_to_i(bool)
      if bool
        1
      else
        0
      end
    end

    def find_or_create
      res = get(path('getsyncfolders'))
      folder_list = res.parsed_response['folders']
      if folder_list.map { |f| f['name'] }.include? name
        true
      else
        res = get(path('addsyncfolder'), query: { name: name, secret: secret })
      end
    end
  end
end