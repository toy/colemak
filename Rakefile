# encoding: utf-8

exec 'rake' if $0 == __FILE__

$LOAD_PATH << 'lib'

require 'pathname'
require 'keylayout'

task :default => :build

rule '.iconset/icon_16x16.png' => proc{ |tn| tn.sub(/\.iconset\/icon_16x16\.png$/, '.png') } do |t|
  iconset = Pathname(t.name).dirname
  rm_r iconset if iconset.exist?
  mkpath iconset
  cp t.source, t.name
end

rule '.icns' => proc{ |tn| tn.sub(/\.icns$/, '.iconset/icon_16x16.png') } do |t|
  sh *%W[iconutil --convert icns --output #{t.name} #{File.dirname(t.source)}]
end

file 'Cölemak.bundle' => %w[Rakefile icons/en.icns icons/ru.icns] + Dir['{**/*.rb,{keylayouts,resources}/*.*}'] do |t|
  bundle = Pathname(t.name)
  contents = bundle + 'Contents'
  resources = contents + 'Resources'
  lproj = resources + 'English.lproj'

  rm_r bundle if bundle.exist?
  mkpath lproj

  cp 'resources/Info.plist', contents
  cp 'resources/version.plist', resources
  cp 'resources/InfoPlist.strings', lproj
  cp 'icons/en.icns', resources + 'Cölemak.icns'
  cp 'icons/ru.icns', resources + 'Cölemak ru.icns'

  kl = Keylayout.read('keylayouts/colemak-apple.keylayout')
  ru = Keylayout.read('keylayouts/ru.keylayout')

  # keep only one layout
  layout = kl.layout(0)
  kl.layouts = [layout]

  # there is no caps in Colemak
  layout.modifier_map.each do |_, keys_list|
    keys_list
      .each{ |keys| keys.delete('caps?') }
      .delete_if{ |keys| keys.include?('caps') }
  end
  layout.modifier_map.compact!

  # additions
  layout.key_map_for([]).tap do |base_key_map|
    alt_key_map = layout.key_map_for(%w[option])
    alt_shift_key_map = layout.key_map_for(%w[option shift])

    [
      %w[1 ¹],
      %w[2 ²],
      %w[3 ³],
      %w[8 ×],
    ].each do |base, output|
      alt_key_map[base_key_map.code(base)] = output
    end

    [
      %w[v ⇧],
      %w[b ⌃],
      %w[k ⌥],
      %w[m ⌘],
      %w[, ⎋],
      %w[. …],
      %w[/ ],
    ].each do |base, output|
      alt_shift_key_map[base_key_map.code(base)] = output
    end

    [
      %w[a ä Ä],
      %w[o ö Ö],
      %w[u ü Ü],
      %w[i ï Ï],
      %w[§ ✓ ✗],
      %w[4 € £],
      %w[5 ¢ ¥],
      %w{[ « ‹},
      %w{] » ›},
      %w[\\ \\ |],
    ].each do |base, small, capital|
      code = base_key_map.code(base)
      alt_key_map[code] = small
      alt_shift_key_map[code] = capital
    end
  end

  kl.group = 0
  kl.id = 1
  kl.name = 'Cölemak'
  (resources + 'Cölemak.keylayout').write(kl.to_xml)

  # separate base empty from command set
  layout.modifier_map.add(Keylayout::Index.new(id: -1), [])
  layout.modifier_map.each do |_, keys_list|
    keys_list.delete_if{ |keys| keys == Set['command?'] }
  end

  # fixes and additions
  layout.key_map_for([]).tap do |base_key_map|
    layout.key_map_for(%w[command]).each do |code, result|
      base_key_map[code] = result
    end

    alt_key_map = layout.key_map_for(%w[option])
    alt_shift_key_map = layout.key_map_for(%w[option shift])
    shift_key_map = layout.key_map_for(%w[shift])

    ru_layout = ru.layout(0)
    ru_base_key_map = ru_layout.key_map_for([])
    ru_shift_key_map = ru_layout.key_map_for(%w[shift])

    %w[; [ ] ' /].each do |output|
      code = base_key_map.code(output)
      alt_key_map[code] = output
      alt_shift_key_map[code] = shift_key_map[code]
    end

    codes = %w[
      q w f p g j l u y ; [ ]
      a r s t d h n e i o '
      z x c v b k m , .
    ].map{ |output| base_key_map.code(output) }

    {
      ru_base_key_map => base_key_map,
      ru_shift_key_map => shift_key_map,
    }.each do |from, to|
      codes.each do |code|
        to[code] = from[code]
      end
    end

    code = base_key_map.code('/')
    base_key_map[code] = ','
    shift_key_map[code] = '.'

    code = base_key_map.code('§')
    alt_key_map[code] = 'ё'
    alt_shift_key_map[code] = 'Ё'
  end

  kl.group = 7
  kl.id = 2
  kl.name = 'Cölemak ru'
  (resources + 'Cölemak ru.keylayout').write(kl.to_xml)
end

desc 'Build bundle'
task build: 'Cölemak.bundle'

desc 'Remove products'
task :clean do
  rm_r 'Cölemak.bundle', force: true
end
