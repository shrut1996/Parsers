import ply.lex as lex
import re
import sys

tokens = ( 'AT',
           'NEWLINE',
           'COMMENT',
           'WHITESPACE',
           'JUNK',
           'NUMBER',
           'NAME',
           'LBRACE',
           'RBRACE',
           'LPAREN',
           'RPAREN',
           'EQUALS',
           'HASH',
           'COMMA',
           'QUOTE',
           'STRING'  )

t_ignore = ' \v\t\r'

t_AT = r'\@'
t_NEWLINE = r'\n'
t_COMMENT = r'\%~[\n]*\n'
t_WHITESPACE = r'[\ \r\t]+'
t_JUNK = r'~[\@\n\ \r\t]+'
t_NAME = r'[A-Za-z0-9\!\$\&\*\+\-\.\/\:\;\<\>\?\[\]\^\'\_\|]+' 
t_LBRACE = r'\{' 
t_RBRACE = r'\}' 
t_LPAREN = r'\('
t_RPAREN = r'\)'
t_EQUALS = r'='
t_HASH = r'\#'
t_COMMA = r','
t_QUOTE = r'\"'
t_STRING = r'{[^{}]+}'


def t_NUMBER(t):
	r'\[0-9]+'
	t.value = int(t.value)
	return t

def t_error(t):
    print("Illegal character '{0}' at line {1}".format(t.value[0], t.lineno))
    t.lexer.skip(1)

lexer = lex.lex()

