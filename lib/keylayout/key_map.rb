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

  private

    def keys
      @keys ||= {}
    end
  end
end
