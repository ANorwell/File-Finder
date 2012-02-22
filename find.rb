require './file_finder'
require 'optparse'

#Build the filter from the command line arguments
filters = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby find.rb path [BOOLEAN ARGUMENT EXPRESSION ...]"
end.parse!

if ARGV.size < 1
  puts "You must supply at least one file path."
end


finder = FileFinder.new(ARGV[1..-1])
finder.find(ARGV[0]).each{|file| puts file}

