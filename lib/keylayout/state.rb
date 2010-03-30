class Keylayout
  class State
    attr_accessor :terminator

    def self.states
      Hash.new do |states, key|
        states[key] = State.new
      end.tap do |states|
        states['none'] = nil
      end
    end
  end
end
