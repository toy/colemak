require_relative 'assert_type'
require_relative 'key_map_set'
require_relative 'modifier_map'

class Keylayout
  class Layout
    include AssertType

    attr_reader :first, :last, :modifier_map, :key_map_set

    def initialize(first:, last:, modifier_map:, key_map_set:)
      self.first = first
      self.last = last
      self.modifier_map = modifier_map
      self.key_map_set = key_map_set
    end

    def first=(first)
      assert_type first, Integer

      @first = first
    end

    def last=(last)
      assert_type last, Integer

      @last = last
    end

    def modifier_map=(modifier_map)
      assert_type modifier_map, ModifierMap

      @modifier_map = modifier_map
    end

    def key_map_set=(key_map_set)
      assert_type key_map_set, KeyMapSet

      @key_map_set = key_map_set
    end

    def hardware_ids_range = first..last

    def key_map_for(keys) = key_map_set.key_map(index: modifier_map.index_for(keys))
  end
end
