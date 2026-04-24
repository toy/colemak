require_relative 'base'

class Keylayout
  class State < Base
    attr_reader :terminator_output

    def initialize(...)
      super
      @terminator_output = nil
    end

    def terminator_output=(terminator_output)
      assert_type terminator_output, String

      @terminator_output = terminator_output
    end

    def inspect = terminator_output ? "<S:#{@id} [#{terminator_output}]>" : "<S:#{@id}>"
  end
end
