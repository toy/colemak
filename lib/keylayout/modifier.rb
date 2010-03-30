require 'set'

class Keylayout
  class Modifier
    KEYS = %w[shift rightShift anyShift  caps  option rightOption anyOption  command  control rightControl anyControl]
    KEY_ORDER = Hash[*KEYS.each_with_index.to_a.flatten]
    def initialize(s)
      @keys = s.split(/\s+/).map(&:to_sym).to_set
    end

    def to_s
      @keys.map(&:to_s).sort_by do |key|
        [
          KEY_ORDER[key[/^(.*?)\??$/, 1]] || KEYS.length,
          key
        ]
      end.join(' ')
    end
  end
end
