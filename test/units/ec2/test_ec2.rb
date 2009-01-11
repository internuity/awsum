require File.expand_path('../../helper', File.dirname(__FILE__))

class ImagesTest < Test::Unit::TestCase
  def setup
    @ec2 = Awsum::Ec2.new('abc', 'xyz')
  end

  context "Images: " do
    context "retrieving a list of images" do
      setup {
        xml = load_fixture('ec2/images')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.images
      }

      should "return an array of images" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Image, @result[0].class
      end
    end

    context "retrieving a single image by id" do
      setup {
        xml = load_fixture('ec2/image')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.image 'ari-f9c22690'
      }

      should "return a single image" do
        assert_equal Awsum::Ec2::Image, @result.class
      end
    end
  end

  context "Instances: " do
    context "Running an instance" do
      setup {
        xml = load_fixture('ec2/run_instances')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.run_instances 'ari-f9c22690'
      }

      should "return an array of instances" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Instance, @result[0].class
      end
    end

    context "retrieving a list of instances" do
      setup {
        xml = load_fixture('ec2/instances')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.instances
      }

      should "return an array of instances" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Instance, @result[0].class
      end
    end

    context "retrieving a single instance by id" do
      setup {
        xml = load_fixture('ec2/instance')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.instance 'i-3f1cc856'
      }

      should "return a single instance" do
        assert_equal Awsum::Ec2::Instance, @result.class
      end
    end
  end
end
