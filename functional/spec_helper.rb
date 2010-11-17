$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'awsum/ec2'
require 'awsum/s3'

def functional(description, &block)
  FakeWeb.allow_net_connect = true
  describe "Functional: #{description}" do
    let(:keys) do
      rc_file = File.join(File.expand_path('~'), '.awsumrc')
      unless File.exists?(rc_file)
        raise 'Unable to run functional specs with out access and secret keys. Place them in ~/.awsumrc'
      end
      YAML.load(File.read(rc_file))
    end

    let(:access_key) { keys['access_key'] }
    let(:secret_key) { keys['secret_key'] }

    instance_eval(&block)
  end
end

def run(description, &block)
  puts description
  yield
end

def wait_for(object, state = 'available')
  print "waiting for #{state} on #{object.class}(#{object.id}) "
  while object.state != state
    sleep 1
    object.reload
    print '.'
  end
  puts
end
