$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib/')
require File.join(File.dirname(__FILE__), '../lib/awsum')

ec2 = Awsum::Ec2.new('1NJXGWMY8MX5G7SE7XG2', '3KRiFrHhnbu+R0RU6PhCycxErWTjT1uVvrnk/euI')

#puts "Images"
#puts "======"
#puts ec2.images(:owners => ['self'])

puts "Image (ami-fc03e695)"
puts "===================="
puts "Result: #{ec2.image('ami-fc03e695').inspect}"
