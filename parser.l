%{
#include <stdio.h>	
#include <stdlib.h>
#include "parser.tab.h"

void yyerror (char *s);
int yylex();

bool comment = false;
%}

digit           [0-9]
letter          [a-zA-Z]      

%%
"var"				   {return VAR;}
"begin"				   {return BEGIN;}
"end"				   {return END;}
"if"				   {return IF;}
"then"				   {return THEN;}
"else"				   {return ELSE;}
"while"				   {return WHILE;}
"function"			    {return FUNC;}
"program"			    {return PROG;}
"int"			        {return INTEGER;}

(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)|(//.*) { return COMM;}
\/\/[^\n\r]+?(?:\*\)|[\n\r])    { return LINE_COMM}
{digit}+                 {yylval = atoi(yytext); return NUMCONST;}

{letter}({letter}|{digit})*			   {yylval.id = yytext[0]; return identifier;}
[ \t\n]                ;
[ \-\+\*\=\;\,\)\]\[\)]           	   {return yytext[0];}
(":="|"*="|"-="|"+="|"||"|"&&"|"--"|"++"|"!="|"==")     {return yytext;}
.                      {fprintf(stderr,"unexpected character \'%s\' on line :%d\n",yytext,yylineno); yyerror ("unexpected character");}
{digit}({letter}|{digit})*                      {fprintf(stderr,"Identifiers must start with a character! Error \'%s\' on line :%d\n",yytext,yylineno); yyerror ("Identifiers must start with a character");}

%%
int yywrap (void) {return 1;}
