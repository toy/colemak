require 'set'
require 'shellwords'
require 'toy/std/pathname'
require 'stringio'

require 'hpricot'
require 'nokogiri'
require 'colored'

def ent_preserve(s)
  s.to_s.gsub('&', '&amp;')
end

def ent_cleanup(s)
  s.to_s.gsub('&amp;', '&')
end

class DumbXml
  def self.cleanup(file)
    data = file.read
    fixed = DumbXml.new(file.read).to_s
    unless data == fixed
      print file
      file.write(fixed)
      puts system(['klcompiler', file].shelljoin + ' > /dev/null') ? ' Ok' : ' Ops'
    end
  end

  def initialize(str)
    parse(str)
  end

  def parse(str)
    @groups = []
    @level = 0
    str = str.gsub(/\="(.*?)"/m) do |val|
      %Q{="#{escape_unescaped($1)}"}
    end

    str.scan(/<.*?>/) do |tag|
      case tag
      when /^<\?/                 # <?xml ?>
        line :'?', tag

      when /^<\!--.*-->$/         # <!--  -->
        # line :'#', tag

      when /^<\!/                 # <!DOCTYPE >
        line :'!', tag

      when /^<\/(.*?)>$/          # </xxx>
        @level -= 1
        line :c, tag

      when /^<(.*?)\s*\/>$/       # <xxx />
        line :s, "<#{$1} />"

      when /^<[^\/](.*?)[^\/]>$/  # <xxx>
        line :o, tag
        @level += 1

      else
        raise "can't handle #{tag.inspect}"
      end
    end
  end

  def to_s
    ''.tap do |str|
      @groups.map do |group|
        level = group[:level]
        group[:lines].sort_by do |line|
          line.split('"').map{ |piece| piece[/\d+/].to_i }
        end.each do |line|
          str << "\t" * level << line << "\n"
        end
      end
    end
  end

private

  def line(type, line)
    if !@groups.last || @groups.last[:type] != type || @groups.last[:level] != @level
      @groups << {:type => type, :level => @level, :lines => []}
    end
    @groups.last[:lines] << line
  end

  def unescape(str)
    str.to_s.
      gsub(/\&([a-zA-Z][a-zA-Z0-9]*);/) { [Hpricot::NamedCharacters[$1] || ??].pack("U*") }.
      gsub(/\&\#([0-9]+);/) { [$1.to_i].pack("U*") }.
      gsub(/\&\#[xX]([0-9a-fA-F]+);/) { [$1.to_i(16)].pack("U*") }
  end

  HTML_ESCAPE = {'&' => '&amp;', '>' => '&gt;', '<' => '&lt;', '"' => '&quot;'}
  def html_escape(s)
    s.to_s.gsub(/[&"><]/){ |c| HTML_ESCAPE[c] }
  end
  alias_method :h, :html_escape

  def escape_unescaped(str)
    ''.tap do |s|
      unescape(str).scan(/./mu) do |c|
        if c.bytes.to_a.length == 1
          i = c.bytes.first
          if i < 32 || i >= 127 || %w[& > < "].include?(c)
            s << '&#x%X;' % i
          else
            s << c
          end
        else
          s << c
        end
      end
    end
  end
end

desc "Cleanup all keylayout files"
task :cleanup do
  Pathname.glob('**/*.keylayout') do |file|
    DumbXml.cleanup(file)
  end
end

desc "Resolve action clashes in russian colemak"
task :duplicate_clashing_actions do
  file = Pathname('Russian Colemak.keylayout')
  doc = Nokogiri::XML(ent_preserve(file.read))

  class ActionId
    class << self
      @@used = Set.new
      @@current = 'a0'
      def next!
        begin
          @@current.sub!(/\d+/){ |m| m.succ }
        end until @@used.add?(@@current)
        @@current
      end

      def <<(id)
        @@used.add(id)
      end
    end
  end

  (doc / '//keyboard/actions/action').each do |action|
    ActionId << action['id']
  end

  actions = Set.new
  (doc / '//keyboard/keyMapSet/keyMap/key').each do |key|
    if action_id = key['action']
      unless actions.add?(action_id)
        action = doc % "keyboard actions action##{action_id}"
        action.dup.tap do |dup_action|
          key['action'] = dup_action['id'] = ActionId.next!
          action.parent << dup_action
        end
      end
    end
  end

  file.write(ent_cleanup(doc.to_xml))
  DumbXml.cleanup(file)
end

desc "Delete duplicate actions"
task :delete_duplicate_actions do
  file = Pathname('Russian Colemak.keylayout')
  doc = Nokogiri::XML(ent_preserve(file.read))

  actions = {}
  to_delete = {}
  (doc / '//keyboard/actions/action').each do |action|
    action_id = action['id']
    action_code = action.children.map(&:to_xml).join('')
    if replace_id = actions[action_code]
      to_delete[action_id] = replace_id
      action.unlink
    else
      actions[action_code] = action_id
    end
  end

  (doc / '//keyboard/keyMapSet/keyMap/key').each do |key|
    if action_id = key['action']
      if replace_id = to_delete[action_id]
        key['action'] = replace_id
      end
    end
  end

  file.write(ent_cleanup(doc.to_xml))
  DumbXml.cleanup(file)
end
