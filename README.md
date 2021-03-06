# BtSync

[![Gem Version](https://badge.fury.io/rb/BtSync.png)](http://badge.fury.io/rb/BtSync)
[![Build Status](https://travis-ci.org/ChrisMacNaughton/BtSync.png?branch=master)](https://travis-ci.org/ChrisMacNaughton/BtSync)
[![Code Climate](https://codeclimate.com/github/ChrisMacNaughton/BtSync.png)](https://codeclimate.com/github/ChrisMacNaughton/BtSync)
[![Coverage Status](https://coveralls.io/repos/ChrisMacNaughton/BtSync/badge.png)](https://coveralls.io/r/ChrisMacNaughton/BtSync)
<a href="http://flattr.com/thing/1591816/" target="_blank"><img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0" /></a>

BtSync is a library to help you interact with Bittorrent Sync in Ruby

## Installation

Add this line to your application's Gemfile:

    gem 'btsync'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install btsync

## Usage

### Using BtSync

```ruby
bittorrent = BtSync.new(options)
```

options is a hash that can contain any of the following options.  The values shown are the defaults if no argument is passed in

```ruby
{
  :protocol => "http",
  :uri => "localhost",
  :port => "8888",
  :user => "",
  :password => ""
}
```

####BtSync::Directory

A system directory managed with Bittorrent Sync is represented as a ```BtSync::Directory```.

On a ```BtSync::Directory``` you can

- Update the secret
- change the settings for
  - Use tracker server
  - Use relay server when required
  - Search LAN
  - SearchDHT network
  - Delete Files to Sync Trash
  - Use Predefined Hosts

## Todo

- [x] Manage predefined hosts
- [x] Allow user authentication

## Known Issues

- [] Bittorrent Sync must be run on a Linux system

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
