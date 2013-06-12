name              "btsync"
maintainer        "Chris MacNaughton"
maintainer_email  "chmacnaughton@gmail.com"
license           "Apache 2.0"
description       "Installs Bittorrent Sync"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.0.1"
recipe            "btsync", "installs BtSync"

depends "apt"

%w{ ubuntu debian }.each do |os|
  supports os
end