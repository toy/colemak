require 'nokogiri'

require_relative 'keylayout/assert_type'
require_relative 'keylayout/base'

require_relative 'keylayout/action'
require_relative 'keylayout/index'
require_relative 'keylayout/key_map'
require_relative 'keylayout/key_map_set'
require_relative 'keylayout/layout'
require_relative 'keylayout/modifier_map'
require_relative 'keylayout/state'

# https://developer.apple.com/library/archive/technotes/tn2056/_index.html
class Keylayout
  include AssertType

  CHAR_ENTITIES = {
    amp: ?&,
    lt: ?<,
    gt: ?>,
    quot: ?",
    apos: ?',
  }
  CHAR_TO_NUM_ENTITIES = CHAR_ENTITIES.to_h{ |name, c| ["&#{name};", "&##{c.ord};"] }
  XML_ENTITIES_REGEXP = /&(#{CHAR_ENTITIES.keys.join('|')});/

  class << self
    using(Module.new do
      refine Nokogiri::XML::Node do
        def fetch(attribute_name)
          self[attribute_name] ||
            fail("expected #{attribute_name} attribute to be present in <#{name}#{attribute_nodes.map(&:to_xml).join}>")
        end
      end
    end)

    def read(path)
      parse(File.read(path))
    end

    def parse(data)
      root = Nokogiri::XML(data).at('./keyboard')

      actions = Action.by_id
      indexes = Index.by_id
      key_map_sets = KeyMapSet.by_id
      modifier_maps = ModifierMap.by_id
      states = State.by_id

      layouts = root.search('./layouts/layout').map do |layout_node|
        Layout.new(
          first: Integer(layout_node.fetch(:first)),
          last: Integer(layout_node.fetch(:last)),
          modifier_map: modifier_maps[layout_node.fetch(:modifiers)],
          key_map_set: key_map_sets[layout_node.fetch(:mapSet)]
        )
      end

      root.search('./modifierMap').each do |modifier_map_node|
        modifier_map = modifier_maps[modifier_map_node.fetch(:id)]

        modifier_map.default_index = indexes[modifier_map_node.fetch(:defaultIndex)]

        modifier_map_node.search('./keyMapSelect').each do |key_map_select_node|
          index = indexes[key_map_select_node.fetch(:mapIndex)]

          key_map_select_node.search('./modifier').each do |modifier_node|
            modifier_map.add(index, modifier_node.fetch(:keys).split(/\s+/))
          end
        end
      end

      root.search('./keyMapSet').each do |key_map_set_node|
        key_map_set = key_map_sets[key_map_set_node.fetch(:id)]

        key_map_set_node.search('./keyMap').each do |key_map_node|
          index = indexes[key_map_node.fetch(:index)]

          key_map = key_map_set.key_map(index:)

          if (base_map_set_id = key_map_node[:baseMapSet])
            base_map_set = key_map_sets[base_map_set_id]
            base_index = indexes[key_map_node.fetch(:baseIndex)]
            key_map.base(base_map_set:, base_index:)
          end

          key_map_node.search('./key').each do |key_node|
            code = Integer(key_node.fetch(:code))

            if (output = key_node[:output])
              key_map[code] = output
            elsif (action_id = key_node[:action])
              key_map[code] = actions[action_id]
            else
              fail "unsupported case #{key_node}"
            end
          end
        end
      end

      root.search('./actions/action').each do |action_node|
        action = actions[action_node.fetch(:id)]
        action_node.search('./when').each do |when_node|
          state = states[when_node.fetch(:state)]

          if (output = when_node[:output])
            extra = when_node.attributes.except('state', 'output')
            fail "not handled attributes: #{extra.keys.join(', ')}" unless extra.empty?

            action.add(state:, result: output)
          else
            extra = when_node.attributes.except('state', 'next')
            fail "not handled attributes: #{extra.keys.join(', ')}" unless extra.empty?

            action.add(state:, result: states[when_node.fetch(:next)])
          end
        end
      end

      root.search('./terminators/when').each do |when_node|
        extra = when_node.attributes.except('state', 'output')
        fail "not handled attributes: #{extra.keys.join(', ')}" unless extra.empty?

        state = states[when_node.fetch(:state)]
        state.terminator_output = when_node.fetch(:output)
      end

      new(
        group: root[:group],
        id: root[:id],
        name: root[:name],
        layouts:
      )
    end
  end

  attr_accessor :group, :id, :name

  attr_reader :layouts

  def initialize(
    group:,
    id:,
    name:,
    layouts:
  )
    @group = group
    @id = id
    @name = name
    @layouts = layouts
  end

  def layout(hardware_id)
    layouts.find{ |layout| layout.hardware_ids_range.cover?(hardware_id) }
  end

  def layouts=(layouts)
    assert_type layouts, Array
    layouts.each do |layout|
      assert_type layout, Layout
    end

    @layouts = layouts
  end

  def modifier_maps = layouts.map(&:modifier_map).uniq

  def key_map_sets = layouts.map(&:key_map_set).uniq

  def to_xml(gap_comments: true, reset_ids: true)
    outputs = Set.new

    actions = Set.new
    key_map_sets.each do |key_map_set|
      key_map_set.each do |index, key_map|
        key_map.each do |code, result|
          case result
          when Action then actions << result
          when String then outputs << result
          end
        end
      end
    end

    states = Set.new
    actions.each do |action|
      action.each do |state, result|
        states << state
        case result
        when State then states << result
        when String then outputs << result
        end
      end
    end

    terminators = Set.new
    states.each do |state|
      terminators << state.terminator_output if state.terminator_output
    end

    # my best guess why maxout is 2 for apple colemak layout
    maxout = max_length(outputs) + max_length(terminators)

    indexes = Set.new
    key_map_sets_to_modifier_maps = Hash.new{ |h, key| h[key] = [] }
    layouts.each do |layout|
      key_map_sets_to_modifier_maps[layout.key_map_set] << layout.modifier_map
      indexes.merge(layout.modifier_map.indexes)
    end

    if reset_ids
      indexes.each_with_index{ |index, i| index.id = i }
      actions.sort.each_with_index{ |action, i| action.id = "a#{i}" }
      states.reject{ |state| state.id == 'none' }.sort.each.with_index(1){ |state, i| state.id = i.to_s }
    end

    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.doc.create_internal_subset('keyboard', nil, 'file://localhost/System/Library/DTDs/KeyboardLayout.dtd')

      xml.keyboard group:, id:, name:, maxout: do
        xml.layouts do
          layouts.each do |layout|
            xml.layout first: layout.first, last: layout.last, modifiers: layout.modifier_map, mapSet: layout.key_map_set
          end
        end

        modifier_maps.each do |modifier_map|
          xml.modifierMap id: modifier_map, defaultIndex: modifier_map.default_index do
            modifier_map.each do |index, keys_list|
              xml.keyMapSelect mapIndex: index do
                keys_list.each do |keys|
                  xml.modifier keys: keys.join(' ')
                end
              end
            end
          end
        end

        key_map_sets.each do |key_map_set|
          required_indexes = key_map_sets_to_modifier_maps[key_map_set].map(&:indexes).inject(:|)

          xml.keyMapSet id: key_map_set do
            required_indexes.sort.each do |index|
              key_map = key_map_set.key_map(index:)

              attributes = {index: index}
              if key_map.base_map_set
                attributes[:baseMapSet] = key_map.base_map_set
                attributes[:baseIndex] = key_map.base_index
              end
              xml.keyMap **attributes do
                with_gaps(key_map.codes) do |gap, code|
                  xml.comment " gap #{gap} " if gap_comments && gap

                  result = key_map[code]
                  case result
                  when String then xml.key code:, output: result
                  when Action then xml.key code:, action: result
                  end
                end
              end
            end
          end
        end

        unless actions.empty?
          xml.actions do
            actions.sort.each do |action|
              xml.action id: action do
                action.each do |state, result|
                  case result
                  when String then xml.when state: state, output: result
                  when State then xml.when state: state, next: result
                  end
                end
              end
            end
          end
        end

        if states.any?(&:terminator_output)
          xml.terminators do
            states.sort.each do |state|
              xml.when state: state, output: state.terminator_output if state.terminator_output
            end
          end
        end
      end
    end.to_xml.gsub(XML_ENTITIES_REGEXP, CHAR_TO_NUM_ENTITIES)
  end

private

  def max_length(strings)
    strings.map(&:length).max || 0
  end

  def with_gaps(codes)
    [-1, *codes.sort].each_cons(2) do |prev, code|
      gap = prev + 1..code - 1
      yield gap.size.zero? ? nil : gap.size == 1 ? gap.first : gap, code
    end
  end
end
