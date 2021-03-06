$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'awsum/ec2'
require 'awsum/s3'

def functional(description, &block)
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

    after(:all) do
      ec2.instances(:filter => {'instance-state-name' => ['running', 'stopped']},
                    :tags => {'Name' => 'awsum.test'}).each do |instance|
        begin
          instance.terminate
          wait_for instance, 'terminated'
        rescue
          puts "Could not terminate instance #{instance.id}"
          puts $!.inspect
          puts $!.backtrace
        end
      end

      ec2.volumes(:filter => {'status' => ['available', 'in-use']},
                  :tags => {'Name' => 'awsum.test'}).each do |volume|
        begin
          volume.delete!
        rescue
          puts "Could not delete volume #{volume.id}"
          puts $!.inspect
          puts $!.backtrace
        end
      end

      ec2.snapshots(:filter => {'status' => ['pending', 'completed']},
                  :tags => {'Name' => 'awsum.test'}).each do |snapshot|
        begin
          snapshot.delete
        rescue
          puts "Could not delete snapshot #{snapshot.id}"
          puts $!.inspect
          puts $!.backtrace
        end
      end
    end
  end
end

def run(description, &block)
  puts description
  yield
end

def wait_for(object, state = 'available')
  print "waiting for #{state} on #{object.class}(#{object.id}) "
  while (object.respond_to?(:state) ? object.state : object.status) != state
    sleep 1
    object.reload
    print '.'
  end
  puts
end
