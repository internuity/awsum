require File.expand_path('../../helper', File.dirname(__FILE__))

class ImagesTest < Test::Unit::TestCase
  context "ImageParser:" do
    context "Parsing the result of a call to DescribeImages" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/images')
        parser = Awsum::Ec2::ImageParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of images" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::Image)
      end

      context ", the first image" do
        setup {
          @image = @result[0]
        }

        should "have the correct id" do
          assert_equal "aki-0d9f7b64", @image.id
        end

        should "have the correct location" do
          assert_equal "oracle_linux_kernels/2.6.18-53.1.13.9.1.el5xen/vmlinuz-2.6.18-53.1.13.9.1.el5xen.manifest.xml", @image.location
        end

        should "have the correct state" do
          assert_equal "available", @image.state
        end

        should "have the correct owner" do
          assert_equal "725966715235", @image.owner
        end

        should "not be marked as public" do
          assert @image.public?
        end

        should "have the correct architecture" do
          assert_equal "x86_64", @image.architecture
        end

        should "have the correct type" do
          assert_equal "kernel", @image.type
        end
      end

      context ", the second image" do
        setup {
          @image = @result[1]
        }

        should "have the correct id" do
          assert_equal "aki-25de3b4c", @image.id
        end

        should "have an array of product codes" do
          assert @image.product_codes.is_a?(Array)
        end

        should "have the corrects product codes" do
          assert_equal "54DBF944", @image.product_codes[0]
        end
      end

      context ", the third image" do
        setup {
          @image = @result[2]
        }

        should "have the correct id" do
          assert_equal "ami-005db969", @image.id
        end

        should "have the correct kernelId" do
          assert_equal "aki-b51cf9dc", @image.kernel_id
        end

        should "have the correct ram disk id" do
          assert_equal "ari-b31cf9da", @image.ramdisk_id
        end
      end
    end
  end

  context "RegisterImageParser:" do
    context "Parsing the result of a call to RegisterImage" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/register_image')
        parser = Awsum::Ec2::RegisterImageParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an image id" do
        assert @result.is_a?(String)
      end

      context ", the image id" do
        setup {
          @image = @result
        }

        should "have the correct id" do
          assert_equal "ami-4782652e", @image
        end
      end
    end
  end
end
