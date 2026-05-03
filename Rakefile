# encoding: utf-8

exec 'rake' if $0 == __FILE__

$LOAD_PATH << 'lib'

require 'fspath'
require 'keylayout'

CÖLEMAK = 'Cölemak'
BUNDLE_NAME = "#{CÖLEMAK}.bundle"
KEYLAYOUT_EN = 'Coelemak en'
KEYLAYOUT_RU = 'Coelemak ru'

task :default => :build

rule '.icns' => '.png' do |t|
  iconset = FSPath("#{t.source.delete_suffix('.png')}.iconset")
  rm_r iconset if iconset.exist?
  mkpath iconset

  {
    16 => %w[16x16],
    32 => %w[16x16@2x 32x32],
    64 => %w[32x32@2x],
  }.each do |size, names|
    paths = names.map{ |name| iconset + "icon_#{name}.png" }
    sh *%W[convert #{t.source} -resize #{size}x #{paths.first}]
    paths.drop(1).each do |path|
      ln paths.first, path
    end
  end

  sh *%W[iconutil --convert icns --output #{t.name} #{iconset}]
end

file BUNDLE_NAME => %w[Rakefile icons/en.icns icons/ru.icns] + Dir['{**/*.rb,{keylayouts,resources}/*.*}'] do |t|
  bundle = FSPath(t.name)
  contents = bundle / 'Contents'
  resources = contents / 'Resources'
  lproj = resources / 'English.lproj'

  rm_r bundle if bundle.exist?
  mkpath lproj

  (contents / 'Info.plist').write <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleIdentifier</key>
      <string>io.github.toy.keyboardlayout.coelemak</string>
      <key>CFBundleName</key>
      <string>#{CÖLEMAK}</string>
      <key>CFBundleVersion</key>
      <string></string>
      <key>KLInfo_#{KEYLAYOUT_EN}</key>
      <dict>
        <key>TICapsLockLanguageSwitchCapable</key>
        <false/>
        <key>TISIconIsTemplate</key>
        <true/>
        <key>TISInputSourceID</key>
        <string>io.github.toy.keyboardlayout.coelemak.#{KEYLAYOUT_EN}</string>
        <key>TISIntendedLanguage</key>
        <string>en</string>
      </dict>
      <key>KLInfo_#{KEYLAYOUT_RU}</key>
      <dict>
        <key>TICapsLockLanguageSwitchCapable</key>
        <false/>
        <key>TISIconIsTemplate</key>
        <true/>
        <key>TISInputSourceID</key>
        <string>io.github.toy.keyboardlayout.coelemak.#{KEYLAYOUT_RU}</string>
        <key>TISIntendedLanguage</key>
        <string>ru</string>
      </dict>
    </dict>
    </plist>
  XML

  (resources / 'version.plist').write <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>BuildVersion</key>
      <string></string>
      <key>ProjectName</key>
      <string>#{CÖLEMAK}</string>
      <key>SourceVersion</key>
      <string></string>
    </dict>
    </plist>
  XML

  (lproj / 'InfoPlist.strings').write <<~STRINGS
    "#{KEYLAYOUT_EN}" = "#{CÖLEMAK}";
    "#{KEYLAYOUT_RU}" = "#{CÖLEMAK} ru";
  STRINGS

  cp 'icons/en.icns', resources + "#{KEYLAYOUT_EN}.icns"
  cp 'icons/ru.icns', resources + "#{KEYLAYOUT_RU}.icns"

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
  kl.id = ENV['RANDOM_KEYLAYOUT_ID'] ? rand(1_000...8_000) * 2 : 1
  kl.name = KEYLAYOUT_EN
  (resources + "#{KEYLAYOUT_EN}.keylayout").write(kl.to_xml)

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

    %w[; [ ] ' \\].each do |output|
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

    code = base_key_map.code('\\')
    base_key_map[code] = ','
    shift_key_map[code] = '.'

    code = base_key_map.code('§')
    alt_key_map[code] = 'ё'
    alt_shift_key_map[code] = 'Ё'
  end

  kl.group = 7
  kl.id += 1
  kl.name = KEYLAYOUT_RU
  (resources + "#{KEYLAYOUT_RU}.keylayout").write(kl.to_xml)
end

desc 'Build bundle'
task build: BUNDLE_NAME

desc 'Remove products'
task :clean do
  rm_r BUNDLE_NAME, force: true
end
