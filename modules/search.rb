#!/usr/bin/env ruby

module Search
  def search
    packages_local = Dir.children('/var/lib/pacman/local') # get only packages names

    if ARGV[0].nil?
      puts 'You have to specify a package to search like yogurt -Ss package name'
      exit

    elsif ARGV[1].nil?
      pkg = ARGV[0]

    elsif ARGV[2].nil?
      pkg = "#{ARGV[0]}-#{ARGV[1]}"

    elsif ARGV[3].nil?
      pkg = "#{ARGV[0]}-#{ARGV[1]}-#{ARGV[2]}"

    elsif ARGV[4].nil?
      pkg = "#{ARGV[0]}-#{ARGV[1]}-#{ARGV[2]}-#{ARGV[3]}"

    else
      pkg = "#{ARGV[0]}-#{ARGV[1]}-#{ARGV[2]}-#{ARGV[3]}-#{ARGV[4]}"
    end

    puts ":: Seaching #{pkg} on aur..."
    url = "https://aur.archlinux.org/rpc/?v=5&type=search&arg=#{pkg}"
    buffer = open(url).read
    obj = JSON.parse(buffer)
    packages = obj['resultcount']
    packages_name = obj['results']

    names = packages_name.map { |result| result['Name'] }
    version = packages_name.map { |result| result['Version'] }
    description = packages_name.map { |result| result['Description'] }

    puts ":: Found #{packages} packages"
    count = 0
    count_to_show = 1
    exit unless packages > count
    while count < packages
      name_and_version = "#{names[count]}-#{version[count]}"
      check = printf("\e[1;34mInstalled\e[0m ") if packages_local.include?(name_and_version)
      puts ":: \e[1;32m#{count_to_show}\e[0m aur/#{names[count]} \e[0;32m#{version[count]}\e[0m #{check}"
      puts "  #{description[count]}"
      count += 1
      count_to_show += 1
    end
  end
end