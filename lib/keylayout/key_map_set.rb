require_relative 'base'
require_relative 'index'
require_relative 'key_map'

class Keylayout
  class KeyMapSet < Base
    include Enumerable

    def initialize(...)
      super
      @key_maps = {}
    end

    def key_map(index:)
      assert_type index, Index

      @key_maps[index] ||= KeyMap.new
    end

    def each(&block) = @key_maps.each(&block)
  end
end
