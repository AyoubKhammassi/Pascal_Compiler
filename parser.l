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

{digit}+                 {yylval.number = atoi(yytext); return NUMCONST;}

{letter}({letter}|{digit})*			   {yylval.identifier = std::string(yytext).c_str() ; printf(yylval.identifier); printf("\n"); return IDENTIFIER;}
{digit}({letter}|{digit})*                      {printf("Identifiers must start with a character! Error \'%s\' on line :%d\n",yytext,yylineno);}


[ \t \n]+           ;
[ \-\+\*\=\;\,\(\]\[\)\:]           	   {return yytext[0];}
(":="|"*="|"-="|"+="|"||"|"&&"|"--"|"++"|"!="|"==")     {printf(yytext) ;return atoi(yytext);}
.                      {printf("unexpected character \'%s\' on line :%d\n",yytext,yylineno);}
"(*"                BEGIN(COMMENT);
"*)"                {printf(" Unexpected end of comment \n"); yyterminate();}
<COMMENT>"*)"      BEGIN(INITIAL);
<COMMENT>.         ;
<COMMENT><<EOF>>    {printf("Comment needs to be closed \n"); yyterminate();}


%%
int yywrap (void) {return 1;}
