if {1 => 1, 2 => 2}.to_s == {2 => 2, 1 => 1}.to_s
  abort 'Need ruby version remembering hash order'
end

class Keylayout
  class Builder
    def initialize
      @xml = ''
      @level = 0
      yield self
    end

    def to_s
      @xml
    end

    def line(str)
      @xml << "\t" * @level << str << "\n"
    end
    alias_method :<<, :line

    def method_missing(method, attributes = {}, &block)
      attributes = attributes.inject(''){ |memo, (k, v)| memo << %{ #{Entities.escape(k)}="#{Entities.escape(v)}"} }
      if block
        line "<#{method}#{attributes}>"
        @level += 1
        block.call
        @level -= 1
        line "</#{method}>"
      else
        line "<#{method}#{attributes} />"
      end
    end
  end
end
