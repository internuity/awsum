require File.expand_path('../../helper', File.dirname(__FILE__))

class ImagesTest < Test::Unit::TestCase
  context "ImageParser:" do
    context "Parsing the result of a call to DescribeImages" do
      setup {
        xml = load_fixture('ec2/images')
        parser = Awsum::Ec2::ImageParser.new
        @result = parser.parse(xml)
      }

      should "return an array of images" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::Image)
      end

      context "" do
        setup {
          @image = @result[0]
        }

        should "have the correct id" do
          assert_equal "ami-be3adfd7", @image.id
        end

        should "have the correct location" do
          assert_equal "ec2-public-images/fedora-8-i386-base-v1.04.manifest.xml", @image.location
        end

        should "have the correct state" do
          assert_equal "available", @image.state
        end

        should "have the correct owner" do
          assert_equal "206029621532", @image.owner
        end

        should "not be marked as public" do
          assert !@image.public?
        end

        should "have the correct architecture" do
          assert_equal "i386", @image.architecture
        end

        should "have the correct type" do
          assert_equal "machine", @image.type
        end

        should "have the correct kernel id" do
          assert_equal "aki-4438dd2d", @image.kernel_id
        end

        should "have the correct ramdisk id" do
          assert_equal "ari-4538dd2c", @image.ramdisk_id
        end
      end
    end
  end
end
