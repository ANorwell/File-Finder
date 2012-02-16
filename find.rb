require './file_finder'
require 'optparse'

#Build the filter from the command line arguments
filters = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby find.rb [--name file_name] [--regex file_regex] path1 [path2 ...]"
  opts.on('-n', '--name [NAME]', 'Search for files with a given name') do |name|
    filters[:name] = name
  end
  opts.on('-r', '--regex [REGEX]',
          'Search with a given (ruby-style) regex') do |regex|
    filters[:regex] = regex
  end
  opts.on('--ctime_min [DAYS]', 'Min creation time in days ago') do |time|
    filters[:ctime_min] = time
  end
end.parse!

if ARGV.size < 1
  puts "You must supply at least one file path."
end

finder = FileFinder.new(filters)
ARGV.each{ |path| puts finder.find(path) }

