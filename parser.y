%{
#include "parser_utils.h"

			
int yyerror(char const *msg);	
int yylex(void);
extern int yylineno;
%}

%token COMM
%token LINE_COMM
%token VAR

%token FUNC PROG INTEGER NUMCONST
%token BEGIN END IDENTIFIER RETURN IF THEN ELSE WHILE 
%start prog

//precedence declarations to avoid reduce/shift conflicts
%left ';'
%left ','
%right ":=" "*=" "+=" "-="
%left "||" 
%left "&&" 
%left "==" "!="
%left '+' '-'
%left '*' 
%right "++" "--" 
%left '(' '['

%parse-param { context cxt } //%param


%%
functions:          |   functions function;
function:           FUNC IDENTIFIER { ++cxt; } '(' paramdecls ')' type var_defs ';' stmnt { --cxt; }; 
paramdecls:         |   paramdecl;
paramdecl:          paramdecl ',' IDENTIFIER type
|                   IDENTIFIER type { cxt.def_param(); };
type:               ':' INTEGER;
stmnt:              rec_stmnt END
|                   IF '(' expr ')' THEN stmnt ELSE stmnt
|                   WHILE '(' expr ')' stmnt
|                   RETURN expr ';'
|                   expr ';'
|                   ';';

rec_stmnt:          BEGIN
|                   rec_stmnt stmnt;

expr:               NUMCONST
|                   IDENTIFIER;
|                   '(' expr ')'                 
|                   expr '[' expr ']'                 
|                   expr '(' ')'                 
|                   expr '(' expr ')'                 
|                   expr '+' expr                
|                   expr '-' expr                
|                   expr '*' expr                
|                   expr ":=" expr 
|                   expr "*=" expr 
|                   expr "+=" expr 
|                   expr "-=" expr
|                   expr "--"
|                   expr "++"
|                   expr "||" expr 
|                   expr "&&" expr 
|                   expr "==" expr 
|                   expr "!=" expr 
|                   expr ',' expr;               


var_defs:           VAR IDENTIFIER '=' expr %prec ','
|                   VAR IDENTIFIER
|                   var_defs ',' IDENTIFIER '=' expr %prec ','
|                   var_defs ',' IDENTIFIER ;


                   
prog:               PROG IDENTIFIER ':'{ ++cxt;} var_defs ';' functions stmnt { --cxt; };
%% 

int yyerror(char const *msg) {
       
	
	fprintf(stderr, "%s %d\n", msg,yylineno);
	return 0;
	
	
}

//extern FILE *yyin;

main()
{
 yyparse();
}
  
                   
