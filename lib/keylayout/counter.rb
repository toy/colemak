class Keylayout
  class Counter
    def initialize(name)
      @name = name
    end

    def next!
      @i = @i ? @i + 1 : 1
      "#{@name}#{@i}"
    end
  end
end
