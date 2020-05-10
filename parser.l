%{
#include <stdio.h>	
#include <stdlib.h>
#include <string>

#include "parser.tab.h"

//void yyerror (char *s);
int yylex();

extern int errno;
int linenumber=1;
%}

digit           [0-9]
letter          [a-zA-Z] 

%option yylineno

%x COMMENT

%%
"var"				   {return VAR;}
"begin"				   {return BEG;}
"end"				   {return END;}
"if"				   {return IF;}
"then"				   {return THEN;}
"else"				   {return ELSE;}
"while"				   {return WHILE;}
"function"			    {return FUNC;}
"program"			    {return PROG;}
"integer"			    {return INTEGER;}
"real"			        {return REAL;}

":="                    {return ASSIGN;}
"||"                    {return OR;}
"&&"                    {return AND;}
"--"                    {return DEC;}
"++"                    {return INC;}
"!="                    {return NOT_EQ;}
"=="                    {return EQ;}
">="                    {return G_EQ;}
"<="                    {return L_EQ;}

{digit}+                 {yylval.number = atoi(yytext); return NUMCONST;}

{letter}({letter}|{digit})*			   { const char *tmp; tmp = strdup(yytext); yylval.identifier = tmp ; return IDENTIFIER;}
{digit}({letter}|{digit})*                      {printf("ERROR: Line %d: Identifiers must start with a character: %s \n",yylineno,yytext); exit(0);}


[ \t \n]+           ;
[ \-\+\*\=\;\,\(\]\[\)\:]           	   {return yytext[0];}

.                      {printf("unexpected character \'%s\' on line :%d\n",yytext,yylineno);}
"(*"                BEGIN(COMMENT);
"*)"                {printf("ERROR: Line %d: Unexpected end of comment \n", yylineno); exit(0);}
<COMMENT>"*)"      BEGIN(INITIAL);
<COMMENT>.         ;
<COMMENT><<EOF>>    {printf("ERROR: Line %d: Comments need to be closed \n", yylineno); exit(0);}


%%
int yywrap (void) {return 1;}
