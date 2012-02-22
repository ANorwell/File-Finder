=begin
A class for Finding files. 
Should be initialized with a list of filters
e.g.
  finder = FileFinder.new({ :name => "name_to_match" })
  finder.find(".")
Searches the current directory recursively for files with name matching
"name_to_match".
If multiple filters provided, they all must match.
This implementation intentionally avoids File.find, since it would be "too
easy", but a proper implementation would use it.
=end
require "./boolean_filter"
class FileFinder
  def initialize(args)
    @boolean_filter = BooleanFilter.new(args)
  end

  def test(dir)
    @boolean_filter.match(dir)
  end
  
  def find(dir)
    #Sanitize dir so that if it is a directory, it doesn't end with a slash.
    #This will prevent '//' from appearing at the start of a file path.
    match = /(.*?)\/$/.match(dir)
    if match
      dir = match[1]
    end
    
    files = []
    if File.exist?(dir) and test(dir)
      files = [dir]
    end
    if not File.directory?(dir)
      return files
    end
    entries = Dir.entries(dir).delete_if{ |d| d == '.' or d == '..' }
    entries.each do |name|
      path = dir + '/' + name
      find(path).each{ |file| files << file }
    end
    files
  end
end
