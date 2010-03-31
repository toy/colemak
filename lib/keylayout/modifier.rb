require 'set'

class Keylayout
  class Modifier
    KEYS = %w[shift rightShift anyShift  caps  option rightOption anyOption  command  control rightControl anyControl]
    KEY_ORDER = Hash[*KEYS.each_with_index.to_a.flatten]

    attr_reader :keys
    def initialize(s)
      @keys = s.split(/\s+/).to_set
    end

    def to_s
      keys.sort_by do |key|
        [
          KEY_ORDER[key[/^(.*?)\??$/, 1]] || KEYS.length,
          key
        ]
      end.join(' ')
    end

    def match?(*pressed)
      pressed = pressed.map(&:to_s)
      (pressed - keys.to_a).empty? && (keys.to_a - pressed).all?{ |key| key[-1] == '?' }
    end
  end
end
