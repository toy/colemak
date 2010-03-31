require 'toy/std/pathname'
require 'shellwords'

require 'nokogiri'

$: << File.dirname(__FILE__)
require 'keylayout/entities'

require 'keylayout/modifier'
require 'keylayout/action'
require 'keylayout/state'
require 'keylayout/key_map'
require 'keylayout/counter'

require 'keylayout/builder'

class Keylayout
  attr_accessor :group, :id, :name
  attr_reader :layout_first, :layout_last, :modifiers_id, :map_set_id, :default_index
  def initialize(data)
    Nokogiri::XML(preserve(data)).tap do |doc|
      doc.at_xpath('//keyboard').tap do |n_keyboard|
        @group = n_keyboard['group']
        @id = n_keyboard['id']
        @name = n_keyboard['name']

        n_keyboard.at_xpath('./layouts/layout').tap do |n_layout|
          @layout_first = n_layout['first']
          @layout_last = n_layout['last']
          @modifiers_id = n_layout['modifiers']
          @map_set_id = n_layout['mapSet']
        end

        modifiers = {}
        n_keyboard.xpath('./modifierMap').each do |n_modifier_map|
          @default_index = n_modifier_map['defaultIndex']
          n_modifier_map.xpath('./keyMapSelect').each do |n_key_map_select|
            modifiers[n_key_map_select['mapIndex']] = n_key_map_select.xpath('modifier').map do |n_modifier|
              Modifier.new(n_modifier['keys'])
            end
          end
        end

        actions = {}
        n_keyboard.xpath('./actions/action').each do |n_action|
          actions[n_action['id']] = Action.new.tap do |action|
            n_action.xpath('./when').each do |n_when|
              action[node_state(n_when)] = case
              when n_when['next']
                node_state(n_when, 'next')
              when n_when['output']
                node_output(n_when, 'output')
              else
                raise "Unknown action result: #{n_when.to_xml}"
              end
            end
          end
        end

        n_keyboard.xpath('./terminators/when').each do |n_when|
          node_state(n_when).terminator = node_output(n_when)
        end

        n_keyboard.xpath('./keyMapSet/keyMap').each do |n_key_map|
          key_map = KeyMap.new.tap do |key_map|
            n_key_map.xpath('./key').each do |n_key|
              key_map[n_key['code']] = case
              when n_key['action']
                actions[n_key['action']].dup
              when n_key['output']
                node_output(n_key)
              else
                raise "Unknown key result: #{n_key.to_xml}"
              end
            end
          end

          key_map.modifiers = modifiers[n_key_map['index']]
          key_maps << key_map
        end
      end
    end
  end

  def states
    @states.values
  end

  def node_state(node, attr = 'state')
    @states ||= State.states
    @states[node[attr]]
  end

  def node_output(node, attr = 'output')
    Entities.unescape(unpreserve(node[attr]))
  end

  def key_maps
    @key_maps ||= []
  end

  def key_map_by_modifier(*pressed)
    key_maps.find{ |key_map| key_map.modifiers.any?{ |modifier| modifier.match?(*pressed) } }
  end

  def maxout
    [
      key_maps.map{ |key_map| [key_map.outputs, key_map.actions.map(&:outputs)] },
      states.compact.map(&:terminator)
    ].flatten.map(&:length).max
  end

  def to_xml
    s = Counter.new('s')
    a = Counter.new('a')

    state_ids = states.each_with_object({}) do |state, hash|
      hash[state] = state ? s.next! : 'none'
    end
    action_ids = Hash.new do |hash, action|
      hash[action] = a.next!
    end

    key_maps.map(&:actions).flatten.sort_by do |action|
      state_id = state_ids[action[nil]]
      state_id ? [0, state_id] : [1]
    end.each do |action|
      action_ids[action]
    end

    Builder.new do |b|
      b << %{<?xml version="1.0" encoding="UTF-8"?>}
      b << %{<!DOCTYPE keyboard SYSTEM "file://localhost/System/Library/DTDs/KeyboardLayout.dtd">}
      b.keyboard group: group, id: id, name: name, maxout: maxout do
        b.layouts do
          b.layout first: layout_first, last: layout_last, modifiers: modifiers_id, mapSet: map_set_id
        end

        b.modifierMap id: modifiers_id, defaultIndex: default_index do
          key_maps.each_with_index do |key_map, i|
            b.keyMapSelect mapIndex: i do
              key_map.modifiers.each do |modifier|
                b.modifier keys: modifier.to_s
              end
            end
          end
        end

        b.keyMapSet id: map_set_id do
          key_maps.each_with_index do |key_map, i|
            b.keyMap index: i do
              key_map.codes.sort.each do |code|
                case result = key_map[code]
                when String
                  b.key code: code, output: result
                when Action
                  b.key code: code, action: action_ids[result]
                else
                  raise "Unknown key result: #{result.inspect}"
                end
              end
            end
          end
        end

        b.actions do
          action_ids.sort_by{ |action, id| id[/\d+/].to_i }.each do |action, id|
            b.action :id => id do
              action.states.each do |state|
                case result = action[state]
                when String
                  b.when state: state_ids[state], output: result
                when State
                  b.when state: state_ids[state], next: state_ids[result]
                else
                  raise "Unknown action result: #{result.inspect}"
                end
              end
            end
          end
        end

        b.terminators do
          state_ids.sort_by{ |state, id| id[/\d+/].to_i }.each do |state, id|
            if state
              b.when state: id, output: state.terminator
            end
          end
        end
      end
    end.to_s
  end


  def self.read(path)
    new(Pathname(path).read)
  end

  def write(path)
    Pathname(path).write(to_xml)
    abort unless system(['klcompiler', path].shelljoin + ' > /dev/null')
  end

private

  def preserve(s)
    s.gsub('&', '&amp;')
  end

  def unpreserve(s)
    s.gsub('&amp;', '&')
  end
end
