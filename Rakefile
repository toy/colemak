# encoding: utf-8

desc "Build keylayouts bundle"
task :build do
  require 'lib/keylayout'

  kl = Keylayout.read('source/Colemak.keylayout')
  kl.key_maps.each do |key_map|
    [64, 79, 80].each do |code|
      key_map[code] ||= "\x10"
    end
  end
  {7 => '×', 11 => '⇧', 45 => '⌃', 46 => '⌥', 43 => '⌘', 42 => '', 47 => '…', 44 => '⎋'}.each do |code, output|
    kl.key_maps[4][code] = output
  end
  # todo: find key_map by modifiers
  # todo: set key output
  # todo: set key output or action output

  kl.write('Colemak.keylayout')
end
