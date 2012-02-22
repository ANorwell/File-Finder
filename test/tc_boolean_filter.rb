require './boolean_filter.rb'
require 'test/unit'
class TestFilterParser < Test::Unit::TestCase

  def test_empty
    tree_root = FilterParser.new.parse([])
    assert(tree_root.class.to_s == 'LeafNode')
  end
  
  def test_leaf
    tree_root = FilterParser.new.parse(['name', 'a'])
    assert(tree_root.class.to_s == 'LeafNode')
  end

  def test_leaf_2
    tree_root = FilterParser.new.parse(['regex', 'b'])
    assert(tree_root.class.to_s == 'LeafNode')
  end
  
  def test_leaf_not_filter
    assert_raise(ArgumentError) do
      tree_root = FilterParser.new.parse(['not_filter', 'a'])
    end 
  end

  def test_bracket_leaf
    tree_root = FilterParser.new.parse(['(', 'name', 'a', ')'])
    assert(tree_root.class.to_s == 'LeafNode')
  end

  def test_and
    tree_root = FilterParser.new.parse(['name', 'ab', 'AND', 'regex', 'b'])
    assert_equal('AndNode', tree_root.class.to_s)
    assert_equal(2, tree_root.children.size)
    assert(tree_root.true?('ab'))
  end

  def test_not
    tree_root = FilterParser.new.parse(['NOT', 'name', 'a'])
    assert_equal('NotNode', tree_root.class.to_s)
    assert_equal(1, tree_root.children.size)
    assert(! tree_root.true?('a'))
    assert(tree_root.true?('b'))
  end

  def test_bracket_not
    tree_root = FilterParser.new.parse(['(', 'NOT', 'name', 'a', ')'])
    assert_equal('NotNode', tree_root.class.to_s)
    assert_equal(1, tree_root.children.size)
  end

  def test_or
    tree_root = FilterParser.new.parse(['name', 'a', 'OR', 'regex', 'b'])
    assert_equal('OrNode', tree_root.class.to_s)
    assert_equal(2, tree_root.children.size)
    assert(tree_root.true?('a'))
    assert(tree_root.true?('b'))
  end  
  def test_bracket_or
    tree_root = FilterParser.new.parse(['(', 'name', 'a', ')', 'OR', 'regex', 'b'])
    assert_equal('OrNode', tree_root.class.to_s)
    assert_equal(2, tree_root.children.size)
    assert(tree_root.true?('bbbb'))
    assert(tree_root.true?('a'))
    assert(! tree_root.true?('aa'))
  end

  def test_bracket_not_or
    tree_root = FilterParser.new.parse(['(', 'NOT', 'name', 'a', ')', 'OR', 'regex', 'b'])
    assert_equal('OrNode', tree_root.class.to_s)
    assert_equal(2, tree_root.children.size)
  end

  def test_bracket_complicated
    tree_root = FilterParser.new.parse(%w[ ( ( NOT name a ) AND ( NOT name b ) ) ] ) 
    assert_equal('AndNode', tree_root.class.to_s)
    assert_equal(2, tree_root.children.size)
    assert(tree_root.true?('c'))
    assert(! tree_root.true?('a'))
  end  
end
