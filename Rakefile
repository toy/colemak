# encoding: utf-8

task :default => :build

desc "Build bundle"
task :build do
  require 'lib/keylayout'

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
    kl.key_map_by_modifier(:anyOption, :anyShift).tap do |dst_key_map|
      {
        'x' => '×',
        'b' => '⇧',
        'k' => '⌃',
        'm' => '⌥',
        ',' => '⌘',
        '.' => '…',
        '\\' => '',
        '/' => '⎋'
      }.each do |output, alt_shift_output|
        code = base_key_map.code(output)
        dst_key_map[code] = alt_shift_output
      end
    end
  end

  # english version ready
  kl.write('Colemak.keylayout')

  kl.key_map_by_modifier().tap do |base_key_map|
    codes = %w[
      q w f p g j l u y ; [ ]
      a r s t d h n e i o ' \\
      z x c v b k m , .
    ].map{ |output| base_key_map.code(output) }
    russian.key_maps.zip(kl.key_maps).each do |russian_key_map, key_map|
      codes.each do |code|
        key_map.set_key_or_action_output(code, russian_key_map[code])
      end
    end
  end

  # russian version ready
  kl.write('Russian Colemak.keylayout')
end
