
/* definitions */

%{
#include<stdio.h>
#include "y.tab.h"
extern YYSTYPE yylval;

char buffer_char;
char buffer_str[100];
char* ptr_str;

int yycol = 0;
int yycol_start = 0;
int yylineno_start = 0;

int i = 0;

%}

newline     \n
whitespace  [ \t]+

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]



%x STRING
%x COMMENT

%%

 /* rules */ 


"/*""*/"			{yycol = yycol + 4;}


{newline}			{yylineno++; yycol = 0;}

"/*"([^/][^*]*"*")*"/"	{
						yycol_start = yycol;
						yylineno_start = yylineno;
						printf("scanner found '%s'\n", yytext);
						for (i = 0; i < yyleng; i++)
						{
							yycol++;
							if ( *(yytext + i) == '\n')
							{
								yylineno++;
								yycol = 0;
								printf("scanner found newline\n");
							}
						}
					}

"/*"([^/][^*]*"*")*	{return ERROR_COM;}


'{digit}'			{buffer_char = *(yytext + 1); return CHARCONST;}
'.'					{buffer_char = *(yytext + 1); return CHARCONST;}
'\\t'				{buffer_char = '\t'; return CHARCONST;}
'\\n'				{buffer_char = '\n'; return CHARCONST;}
'\\\\'				{buffer_char = '\\'; return CHARCONST;}
'\\\"'				{buffer_char = '"'; return CHARCONST;}

\"					{yycol_start = yycol; yycol++; BEGIN STRING; ptr_str = buffer_str;}
<STRING>\\n			{yycol = yycol + yyleng; *ptr_str++ = '\n';}
<STRING>\\t			{yycol = yycol + yyleng; *ptr_str++ = '\t';}
<STRING>\\\"		{yycol = yycol + yyleng; *ptr_str++ = '\"';}
<STRING>\"			{
						yycol++;
						*ptr_str = 0;
						BEGIN 0;
						/*  printf("found '%s'\n", buffer_str);  */
						return STRCONST;
					}
<STRING>\n			{
						BEGIN 0;
						yylineno++;
						yycol = 0;
						return ERROR_STR;
					}
<STRING>.			{yycol++; *ptr_str++ = *yytext;}


[0]					{yycol = yycol + yyleng; yylval.value = atoi(yytext); return INTCONST;}
[1-9][0-9]*			{yycol = yycol + yyleng; yylval.value = atoi(yytext); return INTCONST;}

"int"				{yycol = yycol + yyleng; yylval.value = KWD_INT; return KWD_INT;}
"char"				{yycol = yycol + yyleng; return KWD_CHAR;}
"string"			{yycol = yycol + yyleng; return KWD_STRING;}
"void"				{yycol = yycol + yyleng; return KWD_VOID;}
"if"				{yycol = yycol + yyleng; return KWD_IF;}
"else"				{yycol = yycol + yyleng; return KWD_ELSE;}
"while"				{yycol = yycol + yyleng; return KWD_WHILE;}
"return"			{yycol = yycol + yyleng; return KWD_RETURN;}


"+"					{yycol++; return OPER_ADD;}
"-"					{yycol++; return OPER_SUB;}
"*"					{yycol++; return OPER_MUL;}
"/"					{yycol++; return OPER_DIV;}
"<"					{yycol++; return OPER_LT;}
">"					{yycol++; return OPER_GT;}
">="				{yycol++; return OPER_GTE;}
"<="				{yycol++; return OPER_LTE;}
"=="				{yycol++; return OPER_EQ;}
"!="				{yycol++; return OPER_NEQ;}
"="					{yycol++; return OPER_ASGN;}


\[					{yycol++; return LSQ_BRKT;}
\]					{yycol++; return RSQ_BRKT;}
\{					{yycol++; return LCRLY_BRKT;}
\}					{yycol++; return RCRLY_BRKT;}
\(					{yycol++; return LPAREN;}
\)					{yycol++; return RPAREN;}


","					{yycol++; return COMMA;}
";"					{yycol++; return SEMICLN;}
"@"					{yycol++; return AT;}



[a-zA-Z][0-9a-zA-Z]*			{yycol = yycol + yyleng; yylval.strval = strdup(yytext); return ID;}


{whitespace}		{yycol = yycol + yyleng; /* skip whitespace */}
.					{return ILLEGAL_TOK;}





%%

// user routines 

