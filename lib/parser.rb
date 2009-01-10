require 'rexml/document'

module Awsum
  class Parser
    def parse(xml_text)
      REXML::Document.parse_stream(xml_text, self)
      result
    end

    def result
    end

    def tag_start(tag, attributes)
      puts "tag_start: #{tag}, #{attributes.inspect}"
    end

    def text(text)
      puts "text: #{text}"
    end

    def tag_end(tag)
      puts "tag_end: #{tag}"
    end

    def xmldecl(*args)      ; end
  end
end
