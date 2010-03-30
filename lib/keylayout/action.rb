class Keylayout
  class Action
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
      results.eql?(other.send(:results))
    end

  private

    def results
      @results ||= {}
    end
  end
end
