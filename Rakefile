desc "Install to system Library"
task :install do
  require 'pathname'
  dst_dir = Pathname('/Library/Keyboard Layouts')
  Pathname.glob('*.{keylayout,icns}') do |file|
    dst = dst_dir + file
    src = file.expand_path
    dst.unlink if dst.exist?
    dst.make_link(src.expand_path)
  end
end

desc "Cleanup all keylayout files"
task :cleanup do
  require 'set'
  require 'shellwords'
  require 'toy/std/pathname'
  require 'stringio'
  require 'colored'
  require 'hpricot'

  class DumbXml
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

  Pathname.glob('**/*.keylayout') do |file|
    data = file.read
    fixed = DumbXml.new(file.read).to_s
    unless data == fixed
      print file
      file.write(fixed)
      puts system(['klcompiler', file].shelljoin + ' > /dev/null') ? ' Ok' : ' Ops'
    end
  end
end
