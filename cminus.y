%{
#include "globals.h"
#include <stdio.h>
#include <string.h>
int yylex(void);
void yyerror(const char* msg);
void yyError(char* msg);
int ERR = 0;
int last_error_line = -1;
TreeNode* syntaxTree = NULL;
%}

%locations
%define parse.error verbose
%define parse.lac full

%union {
    int ival;
    float fval;
    char* sval;
    TreeNode* tnode;
}

%token <sval> ID TYPE RELOP
%token <ival> INT_TOKEN
%token <fval> FLOAT_TOKEN
%token SEMI COMMA ASSIGNOP 
%token PLUS MINUS STAR DIV AND OR DOT NOT
%token LP RP LB RB LC RC
%token STRUCT RETURN IF ELSE WHILE
%token ERROR_TOKEN

%type <tnode> Program ExtDefList ExtDef Specifier StructSpecifier OptTag Tag
%type <tnode> ExtDecList VarDec FunDec VarList ParamDec
%type <tnode> CompSt DefList StmtList Def DecList Dec Exp Args Stmt

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%right UMINUS
%left LP COMMA RP LB RB DOT
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start Program

%%

Program : ExtDefList { syntaxTree = $1; }
        ;

ExtDefList : ExtDef ExtDefList 
             { 
                 $$ = newNode(ExtDefListK, @1.first_line); 
                 $$->child[0] = $1; 
                 $$->child[1] = $2; 
             }
           | /* empty */ 
             { 
                 $$ = NULL; 
             }
           ;

ExtDef : Specifier ExtDecList SEMI 
         { 
             $$ = newNode(ExtDefK, @1.first_line); 
             $$->child[0] = $1; 
             $$->child[1] = $2; 
         }
       | Specifier SEMI 
         { 
             $$ = newNode(ExtDefK, @1.first_line); 
             $$->child[0] = $1; 
         }
       | Specifier FunDec CompSt 
         { 
             $$ = newNode(ExtDefK, @1.first_line); 
             $$->child[0] = $1; 
             $$->child[1] = $2; 
             $$->child[2] = $3; 
         }
       ;

ExtDecList : VarDec 
             { 
                 $$ = newNode(ExtDecListK, @1.first_line); 
                 $$->child[0] = $1; 
             }
           | VarDec COMMA ExtDecList 
             { 
                 $$ = newNode(ExtDecListK, @1.first_line); 
                 $$->child[0] = $1; 
                 $$->child[1] = $3; 
             }
           | VarDec error ExtDecList { yyError("Syntax error in ExtDecList"); $$ = NULL; }
           ;

Specifier : TYPE 
            { 
                $$ = newNode(SpecifierK, @1.first_line); 
                $$->name = $1; 
            }
          | StructSpecifier 
            { 
                $$ = $1; 
            }
          ;

StructSpecifier : STRUCT OptTag LC DefList RC 
                  { 
                      $$ = newNode(StructSpecifierK, @1.first_line); 
                      $$->child[0] = $2; 
                      $$->child[1] = $4; 
                  }
                | STRUCT Tag 
                  { 
                      $$ = newNode(StructSpecifierK, @1.first_line); 
                      $$->child[0] = $2; 
                  }
                ;

OptTag : ID 
         { 
             $$ = newNode(OptTagK, @1.first_line); 
             $$->name = $1; 
         }
       | /* empty */ 
         { 
             $$ = NULL; 
         }
       ;

Tag : ID 
      { 
          $$ = newNode(TagK, @1.first_line); 
          $$->name = $1; 
      }
    ;

VarDec : ID 
         { 
             $$ = newNode(VarDecK, @1.first_line); 
             $$->name = $1; 
         }
       | VarDec LB INT_TOKEN RB 
         { 
             $$ = newNode(VarDecK, @1.first_line); 
             $$->child[0] = $1; 
             $$->ival = $3; 
         }
       | VarDec LB error RB { yyError("Invalid array size"); $$ = NULL; }
       ;

FunDec : ID LP VarList RP 
         { 
             $$ = newNode(FunDecK, @1.first_line); 
             $$->name = $1; 
             $$->child[0] = $3; 
         }
       | ID LP RP 
         { 
             $$ = newNode(FunDecK, @1.first_line); 
             $$->name = $1; 
         }
       | ID LP error RP { yyError("Invalid function parameter list"); $$ = NULL; }
       ;

VarList : ParamDec COMMA VarList 
          { 
              $$ = newNode(VarListK, @1.first_line); 
              $$->child[0] = $1; 
              $$->child[1] = $3; 
          }
        | ParamDec 
          { 
              $$ = newNode(VarListK, @1.first_line); 
              $$->child[0] = $1; 
          }
        ;

ParamDec : Specifier VarDec 
           { 
               $$ = newNode(ParamDecK, @1.first_line); 
               $$->child[0] = $1; 
               $$->child[1] = $2; 
           }
         ;

CompSt : LC DefList StmtList RC 
         { 
             $$ = newNode(CompStK, @1.first_line); 
             $$->child[0] = $2; 
             $$->child[1] = $3; 
         }
       ;

StmtList : Stmt StmtList 
           { 
               $$ = newNode(StmtListK, @1.first_line); 
               $$->child[0] = $1; 
               $$->child[1] = $2; 
           }
         | /* empty */ 
           { 
               $$ = NULL; 
           }
         ;

Stmt : Exp SEMI 
       { 
           $$ = newNode(StmtK, @1.first_line); 
           $$->child[0] = $1; 
       }
     | CompSt 
       { 
           $$ = $1; 
       }
     | RETURN Exp SEMI 
       { 
           $$ = newNode(StmtK, @1.first_line); 
           $$->child[0] = $2; 
       }
     | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE
       { 
           $$ = newNode(StmtK, @1.first_line); 
           $$->child[0] = $3; 
           $$->child[1] = $5; 
       }
     | IF LP Exp RP Stmt ELSE Stmt 
       { 
           $$ = newNode(StmtK, @1.first_line); 
           $$->child[0] = $3; 
           $$->child[1] = $5; 
           $$->child[2] = $7; 
       }
     | WHILE LP Exp RP Stmt 
       { 
           $$ = newNode(StmtK, @1.first_line); 
           $$->child[0] = $3; 
           $$->child[1] = $5; 
       }
     | Exp error SEMI { yyError("Missing \";\""); $$ = NULL; }
     | Exp error { yyError("Missing \";\""); $$ = NULL; }
     | IF LP Exp RP Exp error ELSE  /* 特殊情况: if (...) exp else */
       { 
           yyError("Missing \";\"");
           $$ = NULL;
       }
     ;

DefList : Def DefList 
          { 
              $$ = newNode(DefListK, @1.first_line); 
              $$->child[0] = $1; 
              $$->child[1] = $2; 
          }
        | /* empty */ 
          { 
              $$ = NULL; 
          }
        ;

Def : Specifier DecList SEMI 
      { 
          $$ = newNode(DefK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $2; 
      }
    | Specifier error SEMI { yyError("Syntax error in Def"); $$ = NULL; }
    | Specifier DecList error { yyError("Missing \";\" in Def"); $$ = NULL; }
    ;

DecList : Dec 
          { 
              $$ = newNode(DecListK, @1.first_line); 
              $$->child[0] = $1; 
          }
        | Dec COMMA DecList 
          { 
              $$ = newNode(DecListK, @1.first_line); 
              $$->child[0] = $1; 
              $$->child[1] = $3; 
          }
        ;

Dec : VarDec 
      { 
          $$ = newNode(DecK, @1.first_line); 
          $$->child[0] = $1; 
      }
    | VarDec ASSIGNOP Exp 
      { 
          $$ = newNode(DecK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    ;

Exp : Exp ASSIGNOP Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp AND Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp OR Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp RELOP Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
          $$->name = $2; 
      }
    | Exp PLUS Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp MINUS Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp STAR Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp DIV Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | LP Exp RP 
      { 
          $$ = $2; 
      }
    | MINUS Exp %prec UMINUS
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $2; 
      }
    | NOT Exp 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $2; 
      }
    | ID LP Args RP 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->name = $1; 
          $$->child[0] = $3; 
      }
    | ID LP RP 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->name = $1; 
      }
    | Exp LB Exp RB 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp LB Exp COMMA Exp RB  /* 特殊情况: a[5,3] */
      { 
          yyError("Missing \"]\"");
          $$ = NULL; 
      }
    | Exp DOT ID 
      { 
          $$ = newNode(ExpK, @1.first_line); 
          $$->child[0] = $1; 
          $$->name = $3; 
      }
    | ID 
      { 
          $$ = newNode(IdK, @1.first_line); 
          $$->name = $1; 
      }
    | INT_TOKEN 
      { 
          $$ = newNode(IntK, @1.first_line); 
          $$->ival = $1; 
      }
    | FLOAT_TOKEN 
      { 
          $$ = newNode(FloatK, @1.first_line); 
          $$->fval = $1; 
      }
    | Exp ASSIGNOP error { yyError("Invalid assignment"); $$ = NULL; }
    | LP error RP { yyError("Syntax error in expression"); $$ = NULL; }
    | ID LP error RP { yyError("Syntax error in function call"); $$ = NULL; }
    | Exp LB error RB { yyError("Invalid array index"); $$ = NULL; }
    | Exp LB Exp error RB { yyError("Missing \"]\""); $$ = NULL; }
    ;

Args : Exp COMMA Args 
       { 
           $$ = newNode(ArgsK, @1.first_line); 
           $$->child[0] = $1; 
           $$->child[1] = $3; 
       }
     | Exp 
       { 
           $$ = newNode(ArgsK, @1.first_line); 
           $$->child[0] = $1; 
       }
     ;

%%

void yyerror(const char* msg)
{
    if (!lexical_error_flag && last_error_line != yylloc.first_line) {
        syntax_error_flag = 1;
        ERR = 1;
        last_error_line = yylloc.first_line;
        fprintf(stderr, "Error type B at Line %d: %s.\n", yylloc.first_line, msg);
    }
}

void yyError(char* msg)
{
    if (!lexical_error_flag && last_error_line != yylloc.first_line) {
        syntax_error_flag = 1;
        ERR = 1;
        last_error_line = yylloc.first_line;
        fprintf(stderr, "Error type B at Line %d: %s.\n", yylloc.first_line, msg);
    }
}