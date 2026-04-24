require_relative 'base'
require_relative 'index'

class Keylayout
  class ModifierMap < Base
    include Enumerable

    SIDED = %w[
      shift
      option
      control
    ].to_h do |modifier|
      capitalized = modifier.capitalize
      ["any#{capitalized}", [modifier, "right#{capitalized}"]]
    end
    KEYS = Set[*SIDED.flat_map(&:last), 'command', 'caps']
    MANDATORY_MODIFIERS = Set[*SIDED.keys, *KEYS]
    OPTIONAL_MODIFIERS = MANDATORY_MODIFIERS.map{ |key| "#{key}?" }.to_set
    MODIFIERS = MANDATORY_MODIFIERS + OPTIONAL_MODIFIERS

    attr_reader :default_index

    def initialize(...)
      super
      @map = {}
    end

    def default_index=(index)
      assert_type index, Index

      @default_index = index
    end

    def add(index, matchers)
      assert_type index, Index
      assert_type matchers, Array, Set
      matchers = matchers.to_set
      fail ArgumentError, "unknown modifier matchers: #{matchers - MODIFIERS}" unless matchers.proper_subset?(MODIFIERS)

      (@map[index] ||= []) << matchers
    end

    def indexes = @map.keys.sort

    def each(&block) = @map.sort.each(&block)

    def compact! = @map.delete_if{ |_, key_list| key_list.empty? }

    def index_for(keys)
      assert_type keys, Array, Set
      keys = keys.to_set
      fail ArgumentError, "unknown keys: #{keys - KEYS}" unless keys.proper_subset?(KEYS)

      indexes = @map.filter_map do |index, matchers_list|
        index if matchers_list.any?{ |mathers| matching_combinations_for(mathers).include?(keys) }
      end

      indexes.last || default_index
    end

  private

    def matching_combinations_for(matchers)
      matchers.reduce([Set[]]) do |combinations, modifier|
        optional = modifier.end_with?('?')
        modifier = modifier.delete_suffix('?') if optional
        variants = SIDED.fetch(modifier, [modifier])

        with_modifier = combinations.flat_map do |pressed|
          variants.map{ |variant| pressed + [variant] }
        end

        optional ? combinations + with_modifier : with_modifier
      end
    end
  end
end
