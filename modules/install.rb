require 'fileutils'
require 'open-uri'
require 'socket'

module Install
  def install_pkg
    if ARGV[1].nil?
      puts 'You have to specify a package from aur repository. Usage: yogurt -S package'
      exit
    elsif ARGV[2]
      puts 'You must specify the exact name of the package, use yogurt -Ss [package] or yogurt package name'
      exit
    else
      pkg = ARGV[1]
    end

    editor = 'vim' # TODO: ask for what editor want to use.

    raise 'EDITOR environment variable is not set' if editor.nil?

    begin
      download = URI.open("https://aur.archlinux.org/cgit/aur.git/snapshot/#{pkg}.tar.gz")
      IO.copy_stream(download, "/tmp/#{pkg}.tar.gz")
      puts ":: Installing #{pkg} from aur"

    rescue SocketError => e
      puts "\n:: Check your internet Connection\n"
      exit

    rescue Exception => e
      puts "Package not found"
      exit
    end

    Dir.chdir '/tmp/'

    tar_longlink = '././@LongLink'
    tar_gz_archive = "#{pkg}.tar.gz"
    destination = '.'
    begin
      Gem::Package::TarReader.new(Zlib::GzipReader.open(tar_gz_archive)) do |tar|
        dest = nil
        tar.each do |entry|
          if entry.full_name == tar_longlink
            dest = File.join destination, entry.read.strip
            next
          end
          dest ||= File.join destination, entry.full_name
          if entry.directory?
            FileUtils.rm_rf dest unless File.directory? dest
            FileUtils.mkdir_p dest, mode: entry.header.mode, verbose: false
          elsif entry.file?
            FileUtils.rm_rf dest unless File.file? dest
            File.open dest, 'wb' do |f|
              f.print entry.read
            end
            FileUtils.chmod entry.header.mode, dest, verbose: false
          elsif entry.header.typeflag == '2'
            File.symlink entry.header.linkname, dest
          end
          dest = nil
        end
      end
    rescue Zlib::GzipFile::Error => error
      puts "#{error.class}: #{error}"
      exit
    end

    File.delete("#{pkg}.tar.gz")

    Dir.chdir "/tmp/#{pkg}"

    print ":: Edit #{pkg} PKGBUILD? [Y/n]"
    system("#{editor} PKGBUILD") unless STDIN.gets.chomp.casecmp('N').zero?
    system('makepkg -csi')

    Dir.chdir '/tmp/'
    FileUtils.rm_r pkg.to_s
  end

  def check_package
    # This function get the mainteiner if a array with maintainers return nil, yogurt exibe a alert!
  end
end
