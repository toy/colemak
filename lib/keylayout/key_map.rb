class Keylayout
  class KeyMap
    attr_accessor :modifiers
    def [](code)
      keys[code]
    end

    def []=(code, result)
      keys[code.to_i] = result
    end

    def codes
      keys.keys
    end

    def code(result)
      keys.key(result) || keys.detect{ |c, r| r.is_a?(Action) && r[nil] == result }.first
    end

  private

    def keys
      @keys ||= {}
    end
  end
end
