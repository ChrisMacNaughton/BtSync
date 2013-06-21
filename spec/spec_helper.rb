# encoding: utf-8
require 'vcr'
require 'webmock'
require 'coveralls'
Coveralls.wear!

def file_fixture(filename)
  open(File.join(File.dirname(__FILE__), 'fixtures', "#{filename.to_s}")).read
end
filename = File.join(File.dirname(__FILE__), 'support', '**', '*.rb')
filename = File.expand_path(filename)
Dir[filename].each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_request { |request| URI(request.uri).host =~ /127\.0\.0\.1/ }
end
