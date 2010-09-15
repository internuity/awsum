require 'rexml/document'

module Awsum
  class Parser #:nodoc:
    def parse(xml_text)
      REXML::Document.parse_stream(xml_text, self)
      result
    end

#--
#Methods to be overridden by each Parser implementation
    def result                      ; end
    def tag_start(tag, attributes)  ; end
    def text(text)                  ; end
    def tag_end(tag)                ; end
    def xmldecl(*args)              ; end
  end
end
