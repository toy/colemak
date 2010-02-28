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

task :default => :install
