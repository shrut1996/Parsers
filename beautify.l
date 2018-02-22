%option noyywrap
%{
	#include <stdio.h>
	#include <stdlib.h>
    #include <string.h>
    #include <assert.h>
	
	#define INDENT (4)
	#define MAXSYMBOLS 200

	int line = 1;
	int column = 4;
	int paren = 0;

	struct entry
	{
	char *lexptr;
	int token;
	};
	struct entry symtab[MAXSYMBOLS];
	int lookup(char *lexeme); // returns index of the symbol table where the lexeme appears, -
	int insert(char *a, int token); // inserts a new entry into a symbol table
	void init(); // initializes the symbol table with preloaded keywordsint lookup(char *lexeme);


	void write_string();
    void write_char();
    void write_oct();
    void write_hex();
    void write_int();
    void write_fp();
    void write_id();
    void write_begin();
    void write_end();
    void write_open();
    void write_close();
    void write_bopen();
    void write_bclose();
    void write_sep();
    void write_op();
    void write_inline();
    void write_comment();
    void write_directive();
    void error();

	void indent();
    void write_html();
    void write_html_char(char);
%}

quote '
ditto   \"
back    \\
digit   [0-9]
exp [eE]([+-]?)({digit}+)
hex [0-9a-fA-F]
alpha   [a-zA-Z_]
ch  [^\\'\"\n]

%%
{ditto}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{quote})*{ditto}   { write_string(); }
{quote}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{ditto}){quote}    { write_char(); }
0([0-7]+)   	{ write_oct();}
0[xX]({hex})+   { write_hex(); }
{digit}+    	{ write_int(); }
{digit}+"."({digit}*)({exp}?)   { write_fp();  }
{alpha}({alpha}|{digit})*(" "|"\n")? 		{ write_id();  }
"{" { write_begin(); }
"}" { write_end(); }
"(" { write_open(); }
")" { write_close(); }
"[" { write_bopen(); }
"]" { write_bclose(); }
";" { write_sep(); }
(\.|\-\>|\+\+|\-\-|&|\*|\+|\-|~|!|\/|\%|\<\<|\>\>|\<|\>|=|==|"||"|"|"|\<=|\>=|!=|\^\||&&|\|\|\?|\*=|\/=|\%=|\+=|\-=|\<\<=|\>\>=|&=|\^=|\|=|,|#|##|;|:|\"|\.\.\.) { write_op(); }
"\/\/"[^\n]*	{ write_inline(); }
"/*" { write_comment(); }
#[^\n]* { write_directive(); }
[ \t\v\n\r\f] ;
{ch} { error(); }

%%

void write_string() {
    printf("<font color='#FF0000'>");
    write_html();
    printf("</font>");
}

void write_char() {
    printf("<font color='#00FFFF'><u>");
    write_html();
    printf("</u></font>");
}

void write_oct() {
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_hex() {
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_int() {
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_fp() {
    printf("<font color='#00FFFF'>");
    write_html();
    printf("</font>");
}

void write_id() {
    char *str = yytext;
	int signal = 0;
	int chk;
	if(str[strlen(str)-1]==' ' | str[strlen(str)-1]=='\n') {
		signal = 1;
		str[strlen(str)-1]=0;
	}
	chk = lookup(str);
	if(chk == -1) {
		insert(str,1);
		printf("<a name='%s'>",str);
		printf("<font color='#0000FF'>");
		write_html();
		printf("</font></a>");
		if(signal==1) putchar(' ');
	}
	else if(chk==0) {
		printf("<font color='#0000FF'><b>");
		write_html();
		printf("</font></b>");
		if(signal==1) putchar(' ');
	}
	else {
		printf("<a href='#%s'>",str);
		printf("<font color='#0000FF'>");
		write_html();
		printf("</font></a>");
		if(signal==1) putchar(' ');
	}
}

void write_begin() {
    indent();
    write_html();
    column += INDENT;
    indent();
}

void write_end() {
    column -= INDENT;
    indent();
    write_html();
    indent();
}

void write_open() {
    write_html();
    paren++;
}

void write_close() {
	write_html();
	paren--;
}

void write_bopen() {
    write_html();
}

void write_bclose() {
    write_html();
}

void write_sep() {
	write_html();
	if(!paren)
		indent();
	else
		putchar(' ');
}

void write_op() {
    printf("<b>");
    write_html();
    printf(" </b>");
}

void write_inline() {
	printf("<font color='#00FF00'>");
	write_html();
	printf("</font>");
	indent();
}

void write_comment() {
    char c, c1;
    printf("<font color='#00FF00'>/*");
    loop:
    while ((c = input()) != '*' && c != 0)
    write_html_char(c);
    write_html_char('*');
    if ((c1 = input()) != '/' && c != 0) {
        unput(c1);
        goto loop;
    }
    if (c != 0)
	write_html_char(c1);
    printf("</font>");
	indent();
}

void write_directive() {
	printf("<font color='#FF00FF'><b>");
	write_html();
	printf("</b></font>");
	indent();
}

void error() {
    assert(0);
}

void indent() {
	printf("\n%-*d",column,line++);
}

void write_html() {
	char *s = yytext;
	while(*s)
		write_html_char(*s++);
}

void write_html_char(char c) {
	switch(c) {
		case '<': printf("&lt;");break;
		case '>': printf("&gt;");break;
		case '"': printf("&quot;");break;
		case '&': printf("&amp;");break;
		default: putchar(c);
	}
}

char* keywords[] = {"auto","break","case","char","const","continue","default","do",
					"double","else","enum","extern","float","for","goto","if","int",
					"long","register","return","short","signed","sizeof","static",
					"struct","switch","typedef","union","unsigned","void","volatile",
					"while"}; 


int insert(char *a, int token){
	int i = 31;
	while(symtab[++i].token != -1);
	if(i >= MAXSYMBOLS) return -1;
	else {
		strncpy(symtab[i].lexptr,a,strlen(a));
		symtab[i].token = token;
		return 0;
	}	
}

int lookup(char *lexeme){
	int i;
	for(i = 0;i<MAXSYMBOLS;i++) {
		if(strcmp(symtab[i].lexptr,lexeme)==0) return symtab[i].token;
	}
	return -1;
}

void init(){
	int i;
	for(i = 0;i<=MAXSYMBOLS;i++) {
		symtab[i].lexptr = malloc(200*sizeof(char));
		symtab[i].token = -1;
	}
	for(i = 0;i<32;i++) {
		symtab[i].lexptr = keywords[i];
		symtab[i].token = 0;
	}
}

int main() {
	FILE *fp;
	fp = freopen("chess.html","w",stdout);
	init();
    printf("<html><pre>\n");
    indent();
	yyin = fopen("chess.c", "r");
    yylex();
    fclose(yyin);
    printf("\n</pre></html>\n");
	fclose(fp);
    return 0;
}