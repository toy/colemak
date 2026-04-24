require_relative 'base'
require_relative 'state'

class Keylayout
  class Action < Base
    include Enumerable

    def initialize(...)
      super
      @results = {}
    end

    def add(state:, result:)
      assert_type state, State
      assert_type result, String, State

      @results[state] = result
    end

    def default = @results.find{ |state, _| state.id == 'none' }&.last

    def each(&block) = @results.each(&block)
  end
end
