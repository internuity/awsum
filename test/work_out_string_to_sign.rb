byte_array = ARGV
str = ""
byte_array.each do |byte|
  str << byte.hex.chr
end

puts str
