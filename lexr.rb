#!/usr/local/bin/ruby


##
# General Lexer error. Generally should only be used by its subclasses
##
class LexerError < StandardError
  def initialize(msg = "Lexer Error")
    super
  end
end

##
# Lexer Option Error - describes an error in setting or accessing an option
##
class LexerOptionError < LexerError
  def initialize(msg = "Lexer option does not exist", option = nil)
    super(msg)
    @option = option if option
    msg = "Lexer option ##{option} does not exist" if option
  end
end

##
# Lexer Value Error - describes an error in setting or accessing an option
##
class LexerValueError < LexerError
  def initialize(msg = "Lexer value does not exist", value = nil)
    super(msg)
    @val = value if value
    msg = "Lexer value ##{value} does not exist" if value
  end
end

class StateError < LexerError
  def initialize(msg = "Lexer state not defined", state = nil)
    super(msg)
    @state = state if state
    msg = "Lexer state #{state} does not exist" if state
  end
end

class DefinitionError < LexerError
  def initialize(msg = "Lexer definition not defined", definition = nil)
    super(msg)
    @definition = definition if definition
    msg = "Lexer definition '#{defintion}' does not exist" if definition
  end
end


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
#               those, instead of things like lookahead. Theoretically, you can, but 
#               just... don't.
##
class Lexer
  def initialize
    @options = {} # put options here
    @values = {}
    @open_states = [:initial]
    @exclusive_states = []
    @states = [:initial]
    @definitions = {}
    @state_rules = {}
    # put option variables here
    yield self if block_given?
  end

  def set(opt)
    opt = opt.to_sym
    if @options[opt]
      @options[opt] = true
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

  #TODO: Maybe put a warning when state declared multiple times
  def open_state(state)
    state = state.to_sym 
    if !@open_states.include?(state)
      @exclusive_states.delete state if @exclusive_states.include?(state)
      @open_states << state
      @states << state
    end
  end

  def exclusive_state(state)
    state = state.to_sym
    if !@exclusive_States.include(state)
      @open_states.delete state if @open_states.include?(state)
      @exclusive_states << state
      @states << state
    end
  end

  def define(name, value)
    if !@definitions[name]
      @definitions[name] = value
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


#  def lex(args*)
#    args.each_with_index
#  end
end
