require 'puppet/pops/api/model/model'
require 'puppet/pops/api/visitor'
module Puppet; module Pops; module Impl; module Model

# Base class for formatted textual dump of a "model"
#
class TreeDumper
  attr_accessor :indent_count
  
  def initialize initial_indentation = 0
    @dump_visitor = Puppet::Pops::API::Visitor.new(self,"dump",0,0)
    @indent_count = initial_indentation
  end
  
  def dump(o)
    format(do_dump(o))
  end
  
  def do_dump(o)
    @dump_visitor.visit(o)
  end
  
  def indent
    "  " * indent_count 
  end
      
  def format(x)
    result = ""
    parts = format_r(x)
    parts.each_index do |i|
      if i > 0
        # separate with space unless previous ends with whitepsace or (
        result << ' ' if parts[i] != ")" && parts[i-1] !~ /.*(?:\s+|\()$/ && parts[i] !~ /\s+/
      end
      result << parts[i]
    end
    result
  end
  
  def format_r(x)
    result = []
    case x
    when :break
      result << "\n" + indent
    when :indent
      @indent_count += 1
    when :dedent
      @indent_count -= 1
    when Array
      result << '('
      result += x.collect {|a| format_r(a) }.flatten
      result << ')'
    when Symbol
      result << x.to_s # Allows Symbols in arrays e.g. ["text", =>, "text"]
    else
      result << x
    end
    result 
  end
  def is_nop? o
    o.nil? || o.is_a?(Puppet::Pops::API::Model::Nop)
  end
end
end; end; end; end