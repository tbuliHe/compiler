%{
#include "globals.h"
#include "cminus.tab.h"
#include <stdio.h>

int yycolumn = 1;
int err = 0;
#define YY_USER_ACTION yycolumn += yyleng;
%}

%option yylineno

digit           [0-9]
nzdigit         [1-9]
octdigit        [0-7]
hexdigit        [0-9a-fA-F]
letter          [a-zA-Z_]
identifier      {letter}({letter}|{digit})*
decint          0|{nzdigit}{digit}*
octint          0{octdigit}+
hexint          0[xX]{hexdigit}+
intconst        {hexint}|{octint}|{decint}
float1          {digit}+"."{digit}+([eE][+-]?{digit}+)?
float2          {digit}+[eE][+-]?{digit}+
floatconst      {float1}|{float2}
newline         \n

%%

"/*"            {
    int start_line = lineno;
    int c1, c2;
    c1 = input();
    if (c1 == '\n') lineno++;
    while (1) {
        if (c1 == EOF) {
            fprintf(stderr, "Error type A at Line %d: Unterminated comment.\n", start_line);
            lexical_error_flag = 1;
            err = 1;
            return ERROR_TOKEN;
        }
        if (c1 == '*') {
            c2 = input();
            if (c2 == '/') break;
            if (c2 == '\n') lineno++;
            unput(c2);
        }
        if (c1 == '\n') lineno++;
        c1 = input();
    }
}
"//".*          { /* 单行注释，丢弃 */ }

"int"           { yylval.sval = copyString(yytext); return TYPE; }
"float"         { yylval.sval = copyString(yytext); return TYPE; }
"struct"        { return STRUCT; }
"return"        { return RETURN; }
"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }

";"             { return SEMI; }
","             { return COMMA; }
"="             { return ASSIGNOP; }
">="|"<="|"=="|"!="|">"|"<" { yylval.sval = copyString(yytext); return RELOP; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return STAR; }
"/"             { return DIV; }
"&&"            { return AND; }
"||"            { return OR; }
"."             { return DOT; }
"!"             { return NOT; }
"("             { return LP; }
")"             { return RP; }
"["             { return LB; }
"]"             { return RB; }
"{"             { return LC; }
"}"             { return RC; }

{hexint}        {
    int i = 2;
    for (; yytext[i]; ++i)
        if (!isxdigit(yytext[i])) {
            fprintf(stderr, "Error type A at Line %d: Mysterious character \"%s\".\n", lineno, yytext);
            lexical_error_flag = 1;
            err = 1;
            return ERROR_TOKEN;
        }
    yylval.ival = (int)strtol(yytext, NULL, 0);
    return INT_TOKEN;
}
{octint}        {
    int i = 1;
    for (; yytext[i]; ++i)
        if (yytext[i] < '0' || yytext[i] > '7') {
            fprintf(stderr, "Error type A at Line %d: Mysterious character \"%s\".\n", lineno, yytext);
            lexical_error_flag = 1;
            err = 1;
            return ERROR_TOKEN;
        }
    yylval.ival = (int)strtol(yytext, NULL, 0);
    return INT_TOKEN;
}
{decint}        { yylval.ival = atoi(yytext); return INT_TOKEN; }
{floatconst}    {
    char* endptr;
    yylval.fval = strtof(yytext, &endptr);
    if (*endptr != 0) {
        fprintf(stderr, "Error type A at Line %d: Mysterious character \"%s\".\n", lineno, yytext);
        lexical_error_flag = 1;
        err = 1;
        return ERROR_TOKEN;
    }
    return FLOAT_TOKEN;
}
{identifier}    { yylval.sval = copyString(yytext); return ID; }

{newline}       { lineno++; yycolumn = 1; }
[ \t\r\f]+      { /* 忽略空白 */ }
.               {
    fprintf(stderr, "Error type A at Line %d: Mysterious character \"%s\".\n", lineno, yytext);
    lexical_error_flag = 1;
    err = 1;
    return ERROR_TOKEN;
}

%%

int yywrap(void) {

    return 1;
}