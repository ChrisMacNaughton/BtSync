$:.push File.expand_path("../lib", __FILE__)

require "BtSync"
require 'vcr'
require 'webmock'

def file_fixture(filename)
  open(File.join(File.dirname(__FILE__), 'fixtures', "#{filename.to_s}")).read
end

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|

end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_request { |request| URI(request.uri).host =~ /api\.elocal\.com|127\.0\.0\.1/ }
end
