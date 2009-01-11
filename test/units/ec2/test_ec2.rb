require File.expand_path('../../helper', File.dirname(__FILE__))

class ImagesTest < Test::Unit::TestCase
  def setup
    @ec2 = Awsum::Ec2.new('abc', 'xyz')
  end

  context "Images: " do
    context "retrieve a list of images" do
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

    context "retrieve a single image by id" do
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
end
