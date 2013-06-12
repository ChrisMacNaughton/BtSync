package "python-software-properties"

apt_repository "btsync" do
  uri "http://ppa.launchpad.net/tuxpoldo/btsync/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  key "D294A752"
  keyserver "keyserver.ubuntu.com"
  notifies :run, resources(:execute => "apt-get update"), :immediately
end
package "btsync" do
  action :install
end