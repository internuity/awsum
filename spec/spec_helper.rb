$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'awsum/ec2'
require 'awsum/s3'
require 'fakeweb'

FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.before do
    FakeWeb.clean_registry
  end
end

def fixture(path)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', "#{path}.xml"))
end
