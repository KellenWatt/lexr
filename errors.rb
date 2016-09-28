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
    @option = option if option
    msg = "Lexer option ##{option} does not exist" if option
    super(msg)
  end
end

##
# Lexer Value Error - describes an error in setting or accessing an option
##
class LexerValueError < LexerError
  def initialize(msg = "Lexer value does not exist", value = nil)
    @val = value if value
    msg = "Lexer value ##{value} does not exist" if value
    super(msg)
  end
end

class StateError < LexerError
  def initialize(msg = "Lexer state not defined", state = nil)
    @state = state if state
    msg = "Lexer state #{state} does not exist" if state
    super(msg)
  end
end

class DefinitionError < LexerError
  def initialize(msg = "Lexer definition not defined", definition = nil)
    @definition = definition if definition
    msg = "Lexer definition '#{defintion}' does not exist" if definition
    super(msg)
  end
end

class SourceError < LexerError
  def initalize(msg = "Invalid source provided", source = nil)
    @source = source
    msg = "#{source} is not a valid text source" if source
    msg << "\nSource must respond to :eof? and :getc"
    super(msg)
  end

def warning(msg)
  STDERR.puts(msg)
end

def error(msg, code = 1)
  warning(msg)
  exit(code)
end
