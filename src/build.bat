win_bison .\parser.y -d
win_flex .\parser.l
g++ --std=c++11  .\lex.yy.c .\parser.tab.c  --output ..\bin\pasc