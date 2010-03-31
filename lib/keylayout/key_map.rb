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

    def actions
      keys.values.grep(Action)
    end

    def outputs
      keys.values.grep(String)
    end

    def code(output)
      keys.key(output) || keys.detect{ |code, result| result.is_a?(Action) && result[nil] == output }.first
    end

    def output(code)
      result = self[code]
      result.is_a?(Action) ? result[nil] : result
    end

    def set_key_or_action_output(code, output)
      case self[code]
      when Action
        self[code][nil] = output
      else
        self[code] = output
      end
    end

    def each_pair(&block)
      keys.each(&block)
    end

  private

    def keys
      @keys ||= {}
    end
  end
end
