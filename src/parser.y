%{
#include "parser_utils.h"
			
int yyerror(char const *msg);	
int yylex(void);
extern int yylineno;
context cxt;
%}

%token VAR FUNC PROG INTEGER REAL
%token BEG END RETURN IF THEN ELSE WHILE 
%token ASSIGN ":=" OR "||" AND "&&" DEC "--" INC "++" NOT_EQ "!=" EQ "==" L_EQ "<=" G_EQ ">="

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

//%parse-param { context cxt } //%param


%%
functions:          | functions function;
function:           FUNC IDENTIFIER { ++cxt; cxt.add_func($2);} '(' paramdecls ')' type var_defs stmnt {cxt.def_func(cxt.cur_fun->name).pData = cxt.cur_fun; cxt.cur_fun = nullptr; --cxt;} ; 
paramdecls:         |   paramdecl;
paramdecl:          paramdecl ',' IDENTIFIER type { cxt.def_param($3);}
|                   IDENTIFIER type { cxt.def_param($1);} ;
type:               ':' INTEGER
|					':' REAL;
stmnt:              rec_stmnt END
|                   IF '(' expr ')' THEN stmnt ELSE stmnt
|                   IF '(' expr ')' THEN stmnt 
|                   WHILE '(' expr ')' stmnt
|                   RETURN expr ';'
|                   expr ';'
|                   ';';

rec_stmnt:          BEG
|                   rec_stmnt stmnt;

expr:               NUMCONST
|                   IDENTIFIER {cxt.can_use($1);}
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
|                   expr "<=" expr 
|                   expr ">=" expr 
|                   expr ',' expr;               


var_defs:          
|					rec_var_defs ';';

rec_var_defs:		VAR IDENTIFIER type {cxt.def_var($2);}
|                   VAR IDENTIFIER	{cxt.def_var($2);}
|                   rec_var_defs ',' IDENTIFIER type {cxt.def_var($3);}
|                   rec_var_defs ',' IDENTIFIER 	{cxt.def_var($3);};


                   
prog:               PROG IDENTIFIER ';'{ ++cxt; printf("Compiling program %s ... \n", $2);} var_defs functions stmnt { --cxt; cxt.list_funcs();};
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
  
                   
