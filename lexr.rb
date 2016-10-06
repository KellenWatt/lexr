#!/usr/local/bin/ruby
#depends errors.rb

require_relative "errors"
require "stringio"

##
# Lexer class - functions similarily to the GNU 'flex' tool, except instead of generating
#               the code for a new lexical analyzer, it simply acts as the lexer itself.
#               It is strictly a lexer, not a generator. However it would likely be
#               trivial to create one based upon this code, or by opening the class.
#               
#               Actually, yeah. All you would have to do is write a "compile" function 
#               that generates code instead of doing the parsing directly. Not too bad.
#
#               It's worth noting that the rules are defined to eventually use Ruby's 
#               built-in Regexp type. Flex uses actual regular expressions. Please use
#               those guidelines, instead of things like lookahead. Theoretically, you 
#               should be able to use those features, but just... don't... please.
##
class Lexer
  def initialize
    @options = {} # put options here
    @lexr = {lineno: nil, 
             text:   nil, 
             in:     nil,
             state:  :initial}
    @open_states = [:initial]
    @exclusive_states = []
    @states = [:initial]
    @definitions = {}
    @state_rules = Hash.new do |hash, key|
      hash[key] = Hash.new
    end
    @tokens = {}
    @source = nil

    @verbose = false
    yield self if block_given?
  end

  attr_accessor :tokens
  attr_writer :verbose
  
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
    if @lexr[val]
      @lexr[val]
    else
      raise LexerValueError.new(value = val)
    end
  end

  def open_state(state)
    state = state.to_sym 
    unless @open_states.include?(state)
      @exclusive_states.delete(state) if @exclusive_states.include?(state)
      @open_states << state
      @states << state
      puts("Defined open state: #{state}") if @verbose
    else
      warning("Open state #{state} is already defined.")
    end
  end

  def exclusive_state(state)
    state = state.to_sym
    unless @exclusive_states.include(state)
      @open_states.delete(state) if @open_states.include?(state)
      @exclusive_states << state
      @states << state
      puts("Defined exclusive state: #{state}") if @verbose
    else
      warning("Exclusive state #{state} is already defined.")
    end
  end

  def define(name, value)
    unless @definitions[name]
      @definitions[name] = value
      puts("#{name} defined: #{value}") if @verbose
    else
      raise DefinitionError.new("Definition '#{name}' already defined")
    end
  end

  ##
  # action must be a proc, not a lambda. A lambda will be accepted, however it
  # will lead to unexpected behaviour, as an returns will not quit lex().
  ##
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

  ##
  # action must be a proc, not a lambda. A lambda will be accepted, however it
  # will lead to unexpected behaviour, as an returns will not quit lex().
  ##
  def defaultrule(&action)
    @open_states.each do |o|
      @state_rules[o][".\n"] = action
    end
  end

  def parse_rule(rule)
    states = nil
    rule_s = rule.source if rule.is_a?(Regexp)
    if (match = rule_s.match(/(?<=^<).+(?=>)/))
      state_names = match.to_s
      rule_s.gsub!(/<#{state_names}>/, "")
      states = state_names.split(",").map do |s|
        unless @states.include?(s.to_sym)
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
    token_name = name.to_s.to_sym if !name.is_a? Symbol
    @tokens << token_name
  end

  ##
  # As a side-effect of design, calling source() anywhere will necessarily cause
  # the lexer to start from the beginning of the new file. As a consequence, any
  # files that must be lexed in the middle of a file must be included in the file 
  # or stream associated with the include, as changing files from and to the 
  # original will cause it to restart lexing (potentially creating an infinitely 
  # recursive problem)
  ##
  def source(src)
    if src.respond_to?(:getc)
      if src.is_a? String
        if File.exist?(src)
          sourc = File.new(src)
          @lexr[:in] = src
        else
          sourc = StringIO.new(src)
          @lexr[:in] = nil
        end
      end
      @source = sourc
    else
      raise SourceError.new(source = sourc)
    end
  end

  def lex()
    while (c = @source.getc)
      @lexr[:text] << c
      rules = @state_rules[@lexr[:state]]
      
    end
  end
end
