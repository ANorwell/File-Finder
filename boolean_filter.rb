=begin
A class that represents a boolean combination of filters on a file
e.g. ( name foo ) OR ( regex bar )

It should be initialized with a list of tokens that give the filter:

bf = BooleanFilter.new( %w[ ( name foo ) OR ( regex bar ) ] )

Then, to test a file to see if it matches that filter:

bf.match(filename)

which will return true or false.
=end

require './file_filter.rb'
class BooleanFilter
  def initialize(arg_list)
    @parse_root = FilterParser.new.parse(arg_list)
  end

  def match(file)
    @parse_root.true?(file)
  end
end

class ParseNode
  @@type = ''
  def initialize
    @children = []
  end

  def type
    @@type
  end

  def children
    @children
  end

  def add_child(child)
    @children << child
  end
end

class OrNode < ParseNode
  @@type = 'OR'
  def true?(path)
    @children.select{ |c| c.true?(path) }.size > 0
  end
end

class AndNode < ParseNode
  @@type = 'AND'
  def true?(path)
    @children.select{ |c| c.true?(path) }.size == @children.size
  end
end

class NotNode < ParseNode
  @@type = 'NOT'
  def true?(path)
    if (@children.size != 1)
      raise TypeError, "NotNodes should have exactly 1 child in 'true?'"
    end
    not @children[0].true?(path)
  end
end

class LeafNode < ParseNode
  @@type = 'LEAF'
  def initialize(filter)
    @filter = filter
  end

  def true?(path)
    @filter.match(path)
  end
end

class FilterParser
  @@special_tokens = ['AND', 'OR', 'NOT', '(', ')']
  #given a string, returns the root of a tree of parse nodes
  def parse(arglist)
    #if arglist is empty, we should return an empty (always true) filter
    if (arglist.size == 0)
      return LeafNode.new(FileFilter.new({}))
    end
    
    #if it looks like a single filter
    if (arglist.size == 2) and
        (not @@special_tokens.include?(arglist[0])) and
        (not @@special_tokens.include?(arglist[1])) and
      filter = FileFilter.new(arglist[0].to_sym => arglist[1])
      return LeafNode.new(filter)
    end

    if arglist[0] == 'NOT'
      child = parse(arglist[1..-1])
      node = NotNode.new
      node.add_child(child)
      return node
    end

    node = process_ands_and_ors(arglist)
    return node if node

    #there are no root-level booleans, so check if the whole expr is bracketed.
    if (arglist[0] == '(') and (arglist[-1] == ')')
      return parse(arglist[1..-2])
    end
    
    raise ArgumentError, "unable to parse the argument string: #{arglist}"
  end

  private

  def process_ands_and_ors(arglist)
    #find an i such that arglist[0..i-1] and arglist[i+1,-1] are strings
    i = 0
    bracket_depth = 0
    while i < arglist.size
      if arglist[i] == '('
        bracket_depth += 1
      end
      if arglist[i] == ')'
        bracket_depth -= 1
      end

      if ['AND', 'OR'].include?(arglist[i]) and bracket_depth == 0
        first_node = parse(arglist[0..i-1])
        second_node = parse(arglist[i+1..-1])
        if arglist[i] == 'AND'
          node = AndNode.new
        else
          node = OrNode.new
        end
        node.add_child(first_node)
        node.add_child(second_node)
      end
      i += 1
    end

    unless bracket_depth == 0
      raise ArgumentError, "unable to parse the argument string: #{arglist}: bracket error"
    end
    node
  end
end
