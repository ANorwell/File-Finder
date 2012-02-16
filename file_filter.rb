=begin
A class for filtering files
To initialize, should be provided a hash of filters
The different filters and their application are defined by the @@tests
class variable, and are given in the form
     :<filter_name> =>
        lambda { |<file>, <argument>| do_something_and_return_boolean }
where <filter_name> is the name of the test, <file> is the filename to be
tested, <argument> is the argument (passed by user) with the test.
e.g. in the :name test, we want to test that the file basename is an exact
match with argument provided by the user.
=end
class FileFilter
  @@tests = {
    :name => lambda { |file, argument| File.basename(file) == argument },
    :regex => lambda { |file, argument| file =~ /#{argument}/ },
    :ctime_min => lambda do |file, argument|
      #The difference of two time objects is in seconds, but argument is days
      (Time.now - File.stat(file).ctime)/(24*60*60) > argument.to_f
    end
  }

  def initialize(args={})
    @options = {}
    args.each do |k,v|
      if @@tests.has_key?(k)
        @options[k] = v
      else
        raise ArgumentError, "Unknown filter name: #{k}"
      end
    end
  end

  def match(full_file_path)
    match = true
    #Run the testin @@test associated with each provided option
    @options.each do |filter_name, filter_arg|
      if @@tests.has_key?(filter_name)
        match = false unless @@tests[filter_name].call(full_file_path,filter_arg)
      else
        raise ArgumentError, "Unknown filter name: #{filter_name}"
      end
    end
    match
  end
end
