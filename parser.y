%{
#include "parser_utils.h"
			
int yyerror(char const *msg);	
int yylex(void);
extern int yylineno;
context cxt;
%}

%token VAR
%token FUNC PROG INTEGER REAL
%token BEG END RETURN IF THEN ELSE WHILE 
%token END_OF_FILE

%start prog

%union {
	int number;
	const char* identifier;
}
%token <number> NUMCONST
%token <identifier> IDENTIFIER


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
%left ASSIGN

//%parse-param { context cxt } //%param


%%
functions:          | functions function;
function:           FUNC IDENTIFIER { ++cxt; } '(' paramdecls ')' type var_defs stmnt { --cxt; printf("Added new function \n");}; 
paramdecls:         |   paramdecl;
paramdecl:          paramdecl ',' IDENTIFIER type { cxt.def_param(); printf("Added new parameter \n");}
|                   IDENTIFIER type { cxt.def_param($1); printf("Added new parameter \n");} ;
type:               ':' INTEGER
|					':' REAL;
stmnt:              rec_stmnt END
|                   IF '(' expr ')' THEN stmnt ELSE stmnt
|                   WHILE '(' expr ')' stmnt
|                   RETURN expr ';'
|                   expr ';'
|                   ';';

rec_stmnt:          BEG
|                   rec_stmnt stmnt;

expr:               NUMCONST
|                   IDENTIFIER
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


var_defs:          
|					rec_var_defs ';';

rec_var_defs:		VAR IDENTIFIER type {cxt.def_var($2);}
|                   VAR IDENTIFIER	{cxt.def_var($2);}
|                   rec_var_defs ',' IDENTIFIER type {cxt.def_var($3);}
|                   rec_var_defs ',' IDENTIFIER 	{cxt.def_var($3);};


                   
prog:               PROG IDENTIFIER ';'{ ++cxt; printf("Program Started \n");} var_defs functions stmnt { --cxt; };
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
  
                   
