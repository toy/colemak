require_relative 'assert_type'
require_relative 'action'
require_relative 'index'
require_relative 'key_map_set'

class Keylayout
  class KeyMap
    include AssertType
    include Enumerable

    attr_reader :base_map_set, :base_index

    def initialize
      @map = {}
    end

    def base(base_map_set:, base_index:)
      assert_type base_map_set, KeyMapSet
      assert_type base_index, Index

      @base_map_set = base_map_set
      @base_index = base_index
    end

    def base_key_map = @base_map_set&.key_map(index: @base_index)

    def codes = @map.keys

    def [](code) = @map[code]

    def []=(code, result)
      assert_type code, Integer
      assert_type result, String, Action

      @map[code] = result
    end

    def each(&block) = @map.each(&block)

    def code(result)
      codes.find do |code|
        case @map[code]
        when String
          @map[code] == result
        when Action
          @map[code].default == result
        end
      end
    end
  end
end
