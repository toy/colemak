class Keylayout
  class Action
    def dup
      new = super
      @results = @results.dup
      new
    end

    def [](state)
      results[state]
    end

    def []=(state, result)
      results[state] = result
    end

    def states
      results.keys
    end

    def outputs
      results.values.grep(String)
    end

    def hash
      results.hash
    end

    def eql?(other)
      results.eql?(other.send(:results))
    end

  private

    def results
      @results ||= {}
    end
  end
end
