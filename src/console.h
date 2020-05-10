#include <windows.h>

#define BLACK			0
#define GREEN			2
#define RED				4
#define YELLOW			14
#define WHITE			15

extern int yylineno;

void SetColorAndBackground(int ForgC, int BackC=0)
	{
		WORD wColor = ((BackC & 0x0F) << 4) + (ForgC & 0x0F);
		SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), wColor);		
	}

template<typename... types>
void warning(const char* msg, types... o)
{
    SetColorAndBackground(YELLOW, BLACK);
    printf("WARNING: line %d:", yylineno);
    
    SetColorAndBackground(WHITE, BLACK);
    printf(msg, o...);
}

template<typename... types>
void error(const char* msg, types... o)
{
    SetColorAndBackground(RED, BLACK);
    printf("ERROR: line %d:", yylineno);
    SetColorAndBackground(WHITE, BLACK);
    printf(msg, o...);
}
