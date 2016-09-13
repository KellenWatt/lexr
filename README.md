# lexr
###A lexer pseudo-generator in Ruby.

Lexr is a Ruby library to define a lexical analyzer for any given language.

The syntax defined for lexr is similar to GNU flex. However, it does not use, nor require 
flex to be installed on the system. 

There are several notable excpetions to the similarity, namely that the regular expression 
system is built on top of Ruby Regexp's, so it contains their power (although use of 
non-regular aspects, such as backreferences and lookaround are highly discouraged). lexr does 
support states and definitions, as in flex, with similar syntax.

Another such exception is that lexr does not have many of the options of flex, mainly because 
it neither uses tables, nor generates any code. In this regard, lexr is much simpler and 
user-friendly than flex, as long as you are willing to use Ruby, or use a library to invoke 
Ruby code in whatever language you're using.
