require "./file_filter"
require "test/unit"

class TestFilter < Test::Unit::TestCase

  def test_init
    filter = FileFilter.new
    assert(filter)
  end

  def test_name
    filter = FileFilter.new( { :name => "file" } )
    assert filter.match("path/path/file")
    assert !filter.match("path/path/file2")
  end

  #A helper that tests sees if the a given filter matches
  # the strings "file" (should pass) and "other (fail)
  def filter_helper(filter)
    filter = FileFilter.new(filter)
    assert filter.match("file")
    assert !filter.match("other")
  end 
  
  def test_empty_path
    filter_helper({ :name => "file" })
  end

  def test_bad_filter
    assert_raise(ArgumentError){FileFilter.new( { :not_a_filter => "file" } ) }
  end

  def test_regex_basic
    filter_helper( { :regex => "fi" } )
  end

  def test_regex_2
    filter_helper( { :regex => '^f\w+' } )
  end

  def test_multiple_filters
    filter_helper( { :name => 'file',
                     :regex => '^f\w+' } )
  end
  
end
