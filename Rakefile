# encoding: utf-8

exec 'rake' if $0 == __FILE__

task :default => :build

rule '.icns' => proc{ |tn| tn.sub(/\.icns$/, '.iconset/icon_16x16.png') } do |t|
  sh *%W[iconutil --convert icns --output #{t.name} #{File.dirname(t.source)}]
end

desc 'Build bundle'
task build: ['source/icons/Colemak.icns', 'source/icons/Russian Colemak.icns'] do
  require './lib/keylayout'

  bundle = Pathname('Colemak.bundle')
  contents = bundle + 'Contents'
  resources = contents + 'Resources'
  lproj = resources + 'English.lproj'

  rm_r bundle rescue nil
  mkpath lproj

  cp 'source/bundle/Info.plist', contents
  cp 'source/bundle/version.plist', resources
  cp 'source/bundle/InfoPlist.strings', lproj
  cp 'source/icons/Colemak.icns', resources
  cp 'source/icons/Russian Colemak.icns', resources


  kl = Keylayout.read('source/Colemak.keylayout')
  required = Keylayout.read('source/Required.keylayout')
  russian = Keylayout.read('source/Russian excerpt.keylayout')

  # adding required key outputs
  required.key_maps[0].tap do |required_key_map|
    kl.key_maps.each do |key_map|
      required_key_map.each_pair do |code, result|
        key_map[code] ||= result
      end
    end
  end

  # my additions
  kl.key_map_by_modifier().tap do |base_key_map|
    kl.key_map_by_modifier(:anyOption)[base_key_map.code('§')] = '✓'
    kl.key_map_by_modifier(:anyOption, :anyShift).tap do |dst_key_map|
      {
        'v' => '⇧',
        'b' => '⌃',
        'k' => '⌥',
        'm' => '⌘',
        ',' => '⎋',
        '.' => '…',
        '/' => '',
        '§' => '✗',
      }.each do |output, alt_shift_output|
        code = base_key_map.code(output)
        dst_key_map[code] = alt_shift_output
      end
    end

    [
      %w[a ä Ä],
      %w[o ö Ö],
      %w[u ü Ü],
    ].each do |base, small, capital|
      code = base_key_map.code(base)
      kl.key_map_by_modifier(:anyOption)[code] = small
      kl.key_map_by_modifier(:anyOption, :anyShift)[code] = capital
    end
  end

  kl.group = 0
  kl.id = 5005
  kl.name = 'Colemak'

  # english version ready
  kl.write(resources + 'Colemak.keylayout')


  kl.key_map_by_modifier().tap do |base_key_map|
    %w[; [ ] ' \\].each do |output|
      code = base_key_map.code(output)
      shiftOutput = kl.key_map_by_modifier(:anyShift)[code]
      kl.key_map_by_modifier(:anyOption)[code] = output
      kl.key_map_by_modifier(:anyOption, :anyShift)[code] = shiftOutput
      kl.key_map_by_modifier(:anyOption, :caps)[code] = output
    end

    codes = %w[
      q w f p g j l u y ; [ ]
      a r s t d h n e i o '
      z x c v b k m , .
    ].map{ |output| base_key_map.code(output) }
    russian.key_maps.zip(kl.key_maps).each do |russian_key_map, key_map|
      codes.each do |code|
        key_map.set_key_or_action_output(code, russian_key_map[code])
      end
    end

    code = base_key_map.code('\\')
    kl.key_map_by_modifier()[code] = ','
    kl.key_map_by_modifier(:caps)[code] = ','
    kl.key_map_by_modifier(:anyShift)[code] = '.'

    code = base_key_map.code('§')
    kl.key_map_by_modifier(:anyOption)[code] = 'ё'
    kl.key_map_by_modifier(:anyOption, :anyShift)[code] = 'Ё'
    kl.key_map_by_modifier(:anyOption, :caps)[code] = 'Ё'
  end

  kl.group = 7
  kl.id = 19666
  kl.name = 'Russian Colemak'

  # russian version ready
  kl.write(resources + 'Russian Colemak.keylayout')
end
