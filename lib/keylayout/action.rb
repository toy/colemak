class Keylayout
  class Action
    def results
      @results ||= {}
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

    def hash
      results.hash
    end
    def eql?(other)
      results.eql?(other.results)
    end
  end
end
