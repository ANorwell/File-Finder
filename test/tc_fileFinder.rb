require './file_finder'
require 'test/unit'

class TestFind < Test::Unit::TestCase

  def setup
    #The relative location of the directory where we are testing
    @dir = "test/dummy_dir"
    @finder = FileFinder.new({})
  end
  
  def test_init
    assert(@finder)
  end

  def test_find
    files = @finder.find("#{@dir}/dir1")
    assert_equal(3, files.size)
    assert_equal("#{@dir}/dir1", files[0])
  end

  def test_not_exist
    files = @finder.find("#{@dir}/dir_nonsense")
    assert_equal(0, files.size)
  end

  def test_well_formed_dirs
    files = @finder.find("#{@dir}/dir1/")
    assert_equal(3, files.size)
    assert(files.include?("#{@dir}/dir1"))
  end


  #find allows find on a file, which just returns the file itself
  def test_file
    files = @finder.find("#{@dir}/file1")
    assert_equal(1, files.size)
    assert_equal("#{@dir}/file1", files[0])
  end

  def test_recursive
    files = @finder.find("#{@dir}/dir_deep")
    assert_equal(9, files.size)
    assert(files.include?("#{@dir}/dir_deep/dir3/dir/file"))
  end
end

class TestFilteredFind < Test::Unit::TestCase
  def setup
    @dir = "test/dummy_dir"
  end

  #Helper: Given a filter, checks if the recognized file count in
  # #{dir}/dir_deep matches the expected count.
  def filter_find_helper(filter, count)
    @finder = FileFinder.new(filter)
    assert_equal(count, @finder.find("#{@dir}/dir_deep").size)
  end

  def test_find_name
    filter_find_helper({:name => 'dir' }, 3)
  end

  def test_find_regex
    filter_find_helper({:regex => '\/di\w+$' }, 6)
  end

  def test_find_ctime_min
    filter_find_helper({:ctime_min => '0.000001' }, 9)
  end

  
end






