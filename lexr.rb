#!/usr/local/bin/ruby
#depends errors.rb

require_relative "errors"
require "stringio"

##
# Lexer class - functions similar to the GNU 'flex' tool, except instead of generating
#               the code for a new lexical analyzer, it simply acts as the lexer itself.
#               It is strictly a lexer, not a generator. However it would likely be
#               trivial to create one based upon this code, or by opening the class.
#               
#               Actually, yeah. All you would have to do is write a "compile" function 
#               that generates code instead of doing the parsing directly. Not too bad.
#
#               It's worth noting that the rules are defined to eventually use Ruby's 
#               built-in Regexp type. Flex uses actual regular expressions. Please use
#               those, instead of things like lookahead. Theoretically, you can use those
#               features, but just... don't. Please.
##
class Lexer
  def initialize
    @options = {} # put options here
    @values = {lineno: nil, 
               text: nil, 
               len: nil, 
               in: nil, 
               out: nil}
    @open_states = [:initial]
    @exclusive_states = []
    @states = [:initial]
    @definitions = {}
    @state_rules = {}
    @tokens = {}
    @sources = []

    @verbose = false
    yield self if block_given?
  end

  attr_accessor :tokens

  def verbose
    verbose = true
  end

  def noverbose
    verbose = false
  end

  def set(opt)
    opt = opt.to_sym
    if @options[opt]
      @options[opt] = true
      puts("Option set: #{opt}") if @verbose
    else
      raise LexerOptionError.new(option = opt)
    end
  end

  def [](val)
    if @values[val]
      @values[val]
    else
      raise LexerValueError.new(value = val)
    end
  end

  def open_state(state)
    state = state.to_sym 
    if !@open_states.include?(state)
      @exclusive_states.delete state if @exclusive_states.include?(state)
      @open_states << state
      @states << state
      puts("Defined open state: #{state}") if @verbose
    else
      warning("Open state #{state} is already defined.")
    end
  end

  def exclusive_state(state)
    state = state.to_sym
    if !@exclusive_States.include(state)
      @open_states.delete state if @open_states.include?(state)
      @exclusive_states << state
      @states << state
      puts("Defined exclusive state: #{state}") if @verbose
    else
      warning("Exclusive state #{state} is already defined.")
    end
  end

  def define(name, value)
    if !@definitions[name]
      @definitions[name] = value
      puts("#{name} defined: #{value}") if @verbose
    else
      raise DefinitionError.new("Definition '#{name}' already defined")
    end
  end

  def rule(regex, &action)
    states, reg_string = parse_rule(regex)
    states.each do |s|
      if s.nil?
        @open_states.each do |o|
          @state_rules[o][reg_string] = action
        end
      else
        @state_rules[s] = { reg_string => action }
      end
    end
    puts("Rule '#{regex}' defined") if @verbose
  end

  def defaultrule(&action)
    @open_states.each do |o|
      @state_rules[o][".\n"] = action
    end
  end

  def parse_rule(rule)
    states = nil
    rule = rule.source if rule.is_a? Regexp
    if match = rule.match(/(?<=^<).+(?=>)/)
      state_names = match.to_s
      rule.gsub!(/<#{state_names}>/, "")
      states = state_names.split(",").map do |s|
        if !@states.include?(s.to_sym)
          raise StateError.new(state = s)
        end
        s.to_sym
      end
    end

    @definitions.each do |n,r|
      rule.gsub!(/(?<={)#{n}(?=})/, "(#{r})")
    end
    
    return states, rule
  end

  def token(name)
    @tokens << name.to_s.to_sym
  end

  def add_source(src)
    if src.respond_to?(:getc) && src.respond_to?(:eof)
      if src.is_a? String
        if File.exist? src
          src = File.new(src)
        else
          src = StringIO.new(src)
        end
      end
      @sources << src
    else
      raise SourceError.new(source = src)
    end
  end

  def lex()
    
  end
end
