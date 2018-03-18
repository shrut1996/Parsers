import ply.yacc as yacc
import sqlite3
from sqlite3 import IntegrityError
from bib_lexer import tokens

fields = {'bibkey':'null', 'bibtype':'null', 'address':'null', 'author':'null', 'booktitle':'null', 'chapter':'null', 'edition':'null', 'journal':'null', 'number':'null', 'pages':'null', 'publisher':'null', 'school':'null', 'title':'null', 'volume':'null', 'year':'null'}

def make_fields_null():
    for i in fields:
        fields[i]=None

def p_bibfile(p):
    ''' bibfile : entries '''
    p[0] = p[1]

def p_entries(p):
    ''' entries : entry NEWLINE entries
                | entry
    '''
    if len(p) > 2:
        p[0] = p[1] + p[2] + p[3]
    else:
        p[0] = p[1]

def p_entry(p):
    ''' entry : AT NAME LBRACE key COMMA fields RBRACE '''
    p[0] = p[1] + p[2] + p[3] + p[4] + p[5] + p[6] + p[7]
    

    try:
        fields['bibtype'] = p[2]
        fields['bibkey'] = p[4]
        
        sql = '''INSERT INTO bibtex VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'''
        data = (fields['bibkey'], fields['bibtype'], fields['address'], fields['author'],fields['booktitle'],fields['chapter'],fields['edition'],fields['journal'],fields['number'],fields  ['pages'],fields['publisher'],fields['school'],fields['title'],fields['volume'],fields['year']) 
        con.execute(sql,data)
        con.commit()
    except IntegrityError:
        print "Duplicate key found at" , fields['bibkey']
    finally:
        make_fields_null()

def p_key(p):
    ''' key : NAME
            | NUMBER
    '''
    p[0] = p[1]

def p_fields(p):
    ''' fields : field COMMA fields 
			   | field		
	'''
    if len(p) > 2:
        p[0] = p[1] + p[2] + p[3]
    else:
        p[0] = p[1]

def p_field(p):
    ''' field : NAME EQUALS LBRACE value RBRACE
    '''
    p[0] = p[1] + p[2] + p[3] + p[4] + p[5]
    fields[p[1]] = p[4] 

def p_value(p):
    ''' value : NUMBER
              | STRING
              | NAME
    '''
    p[0] = p[1]

start = 'bibfile'
con = sqlite3.connect("compiler.db")
parser = yacc.yacc()


parser.parse("""@article{key1, author={{Sarkar, Santonu}}, title={{John Smith}}}
@book{ourbook, author = {{joe smith and john Kurt}}, title = {{Our Little Book}}, year ={{1997}}}""")


# with open(sys.argv[1], 'r') as f:
#   parser.parse(f.read())

con.close()

