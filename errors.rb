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


def warning(msg)
  STDERR.puts(msg)
end

def fail(msg, code = 1)
  warning(msg)
  exit(code)
end
