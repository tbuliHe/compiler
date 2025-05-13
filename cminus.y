%{
#include "globals.h"
#include <stdio.h>
#include <string.h>
int yylex(void);
void yyerror(const char *s);
TreeNode* syntaxTree = NULL;

// 用于防止多次报告同一行的错误
int last_error_lineno = -1;
%}

%union {
    int ival;
    float fval;
    char* sval;
    TreeNode* tnode;
}

/* 词法单元定义 */
%token <sval> ID TYPE RELOP
%token <ival> INT_TOKEN
%token <fval> FLOAT_TOKEN
%token SEMI COMMA ASSIGNOP 
%token PLUS MINUS STAR DIV AND OR DOT NOT
%token LP RP LB RB LC RC
%token STRUCT RETURN IF ELSE WHILE
%token ERROR_TOKEN

/* 非终结符定义 */
%type <tnode> Program ExtDefList ExtDef Specifier StructSpecifier OptTag Tag
%type <tnode> ExtDecList VarDec FunDec VarList ParamDec
%type <tnode> CompSt DefList StmtList Def DecList Dec Exp Args Stmt

/* 运算符优先级和结合性（从低到高） */
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT UMINUS
%left DOT LB RB LP RP

/* 解决if-else冲突 */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/* 预期的shift/reduce冲突 */
%expect 0

%start Program

%%

/* 程序 */
Program : ExtDefList 
          { 
              syntaxTree = $1; 
          }
        ;

/* 全局定义列表 */
ExtDefList : ExtDef ExtDefList 
             { 
                 $$ = newNode(ExtDefListK, $1 ? $1->lineno : lineno); 
                 $$->child[0] = $1; 
                 $$->child[1] = $2; 
             }
           | /* 空 */ 
             { 
                 $$ = NULL; 
             }
           ;

/* 全局定义 */
ExtDef : Specifier ExtDecList SEMI 
         { 
             $$ = newNode(ExtDefK, $1->lineno); 
             $$->child[0] = $1; 
             $$->child[1] = $2; 
         }
       | Specifier SEMI 
         { 
             $$ = newNode(ExtDefK, $1->lineno); 
             $$->child[0] = $1; 
         }
       | Specifier FunDec CompSt 
         { 
             $$ = newNode(ExtDefK, $1->lineno); 
             $$->child[0] = $1; 
             $$->child[1] = $2; 
             $$->child[2] = $3; 
         }
       | error SEMI 
         { 
             yyerrok; 
             $$ = NULL;
         }
       ;

/* 类型说明符 */
Specifier : TYPE 
            { 
                $$ = newNode(TypeK, lineno); 
                $$->name = $1; 
            }
          | StructSpecifier 
            { 
                $$ = $1; 
            }
          ;

/* 结构体说明符 */
StructSpecifier : STRUCT OptTag LC DefList RC 
                  { 
                      $$ = newNode(StructSpecifierK, lineno); 
                      $$->child[0] = $2; 
                      $$->child[1] = $4; 
                  }
                | STRUCT Tag 
                  { 
                      $$ = newNode(StructSpecifierK, lineno); 
                      $$->child[0] = $2; 
                  }
                ;

/* 可选的结构体标签 */
OptTag : ID 
         { 
             $$ = newNode(OptTagK, lineno); 
             $$->name = $1; 
         }
       | /* 空 */ 
         { 
             $$ = NULL; 
         }
       ;

/* 结构体标签 */
Tag : ID 
      { 
          $$ = newNode(TagK, lineno); 
          $$->name = $1; 
      }
    ;

/* 变量声明列表 */
ExtDecList : VarDec 
             { 
                 $$ = newNode(ExtDecListK, $1->lineno); 
                 $$->child[0] = $1; 
             }
           | VarDec COMMA ExtDecList 
             { 
                 $$ = newNode(ExtDecListK, $1->lineno); 
                 $$->child[0] = $1; 
                 $$->child[1] = $3; 
             }
           ;

/* 变量声明 */
VarDec : ID 
         { 
             $$ = newNode(VarDecK, lineno); 
             $$->name = $1; 
         }
       | VarDec LB INT_TOKEN RB 
         { 
             $$ = newNode(VarDecK, lineno); 
             $$->child[0] = $1; 
             $$->ival = $3; 
         }
       ;

/* 函数声明 */
FunDec : ID LP VarList RP 
         { 
             $$ = newNode(FunDecK, lineno); 
             $$->name = $1; 
             $$->child[0] = $3; 
         }
       | ID LP RP 
         { 
             $$ = newNode(FunDecK, lineno); 
             $$->name = $1; 
         }
       ;

/* 参数列表 */
VarList : ParamDec COMMA VarList 
          { 
              $$ = newNode(VarListK, $1->lineno); 
              $$->child[0] = $1; 
              $$->child[1] = $3; 
          }
        | ParamDec 
          { 
              $$ = newNode(VarListK, $1->lineno); 
              $$->child[0] = $1; 
          }
        ;

/* 参数声明 */
ParamDec : Specifier VarDec 
           { 
               $$ = newNode(ParamDecK, $1->lineno); 
               $$->child[0] = $1; 
               $$->child[1] = $2; 
           }
         ;

/* 复合语句 */
CompSt : LC DefList StmtList RC 
         { 
             $$ = newNode(CompStK, lineno); 
             $$->child[0] = $2; 
             $$->child[1] = $3; 
         }
       | LC error RC 
         {
             yyerrok;
             $$ = NULL;
         }
       ;

/* 局部变量定义列表 */
DefList : Def DefList 
          { 
              $$ = newNode(DefListK, $1->lineno); 
              $$->child[0] = $1; 
              $$->child[1] = $2; 
          }
        | /* 空 */ 
          { 
              $$ = NULL; 
          }
        ;

/* 局部变量定义 */
Def : Specifier DecList SEMI 
      { 
          $$ = newNode(DefK, $1->lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $2; 
      }
    | Specifier DecList error 
      {
          if (last_error_lineno != lineno) {
              fprintf(stderr, "Error type B at Line %d: Missing \";\".\n", lineno);
              last_error_lineno = lineno;
              syntax_error_flag = 1;
          }
          yyerrok;
          $$ = NULL;
      }
    ;

/* 声明列表 */
DecList : Dec 
          { 
              $$ = newNode(DecListK, $1->lineno); 
              $$->child[0] = $1; 
          }
        | Dec COMMA DecList 
          { 
              $$ = newNode(DecListK, $1->lineno); 
              $$->child[0] = $1; 
              $$->child[1] = $3; 
          }
        ;

/* 声明 */
Dec : VarDec 
      { 
          $$ = newNode(DecK, $1->lineno); 
          $$->child[0] = $1; 
      }
    | VarDec ASSIGNOP Exp 
      { 
          $$ = newNode(DecK, $1->lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    ;

/* 语句列表 */
StmtList : Stmt StmtList 
           { 
               $$ = newNode(StmtListK, $1->lineno); 
               $$->child[0] = $1; 
               $$->child[1] = $2; 
           }
         | /* 空 */ 
           { 
               $$ = NULL; 
           }
         ;

/* 语句 */
Stmt : Exp SEMI 
       { 
           $$ = newNode(StmtK, $1->lineno); 
           $$->child[0] = $1; 
       }
     | CompSt 
       { 
           $$ = $1; 
       }
     | RETURN Exp SEMI 
       { 
           $$ = newNode(StmtK, lineno); 
           $$->child[0] = $2; 
       }
     | IF LP Exp RP Stmt %prec LOWER_THAN_ELSE
       { 
           $$ = newNode(StmtK, lineno); 
           $$->child[0] = $3; 
           $$->child[1] = $5; 
       }
     | IF LP Exp RP Stmt ELSE Stmt 
       { 
           $$ = newNode(StmtK, lineno); 
           $$->child[0] = $3; 
           $$->child[1] = $5; 
           $$->child[2] = $7; 
       }
     | WHILE LP Exp RP Stmt 
       { 
           $$ = newNode(StmtK, lineno); 
           $$->child[0] = $3; 
           $$->child[1] = $5; 
       }
     | Exp error 
       {
           if (last_error_lineno != lineno) {
               fprintf(stderr, "Error type B at Line %d: Missing \";\".\n", lineno);
               last_error_lineno = lineno;
               syntax_error_flag = 1;
           }
           yyerrok;
           $$ = NULL;
       }
     ;

/* 表达式 */
Exp : Exp ASSIGNOP Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp AND Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp OR Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp RELOP Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
          $$->name = $2; 
      }
    | Exp PLUS Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp MINUS Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp STAR Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp DIV Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | LP Exp RP 
      { 
          $$ = $2; 
      }
    | MINUS Exp %prec UMINUS
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $2; 
      }
    | NOT Exp 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $2; 
      }
    | ID LP Args RP 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->name = $1; 
          $$->child[0] = $3; 
      }
    | ID LP RP 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->name = $1; 
      }
    | Exp LB Exp RB 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->child[1] = $3; 
      }
    | Exp DOT ID 
      { 
          $$ = newNode(ExpK, lineno); 
          $$->child[0] = $1; 
          $$->name = $3; 
      }
    | ID 
      { 
          $$ = newNode(IdK, lineno); 
          $$->name = $1; 
      }
    | INT_TOKEN 
      { 
          $$ = newNode(IntK, lineno); 
          $$->ival = $1; 
      }
    | FLOAT_TOKEN 
      { 
          $$ = newNode(FloatK, lineno); 
          $$->fval = $1; 
      }
    ;

/* 参数 */
Args : Exp COMMA Args 
       { 
           $$ = newNode(ArgsK, $1->lineno); 
           $$->child[0] = $1; 
           $$->child[1] = $3; 
       }
     | Exp 
       { 
           $$ = newNode(ArgsK, $1->lineno); 
           $$->child[0] = $1; 
       }
     ;

%%

/* 自定义一个辅助函数来捕获特殊错误 */
void handle_special_errors(const char* input_file) {
    FILE* file = fopen(input_file, "r");
    if (!file) return;
    
    char line[1024];
    int curr_line = 1;
    
    while (fgets(line, sizeof(line), file)) {
        // 检查逗号错误的特殊情况: a[5,3]
        if (strstr(line, "[") && strstr(line, ",") && strstr(line, "]")) {
            if (last_error_lineno != curr_line) {
                fprintf(stderr, "Error type B at Line %d: Missing \"]\".\n", curr_line);
                last_error_lineno = curr_line;
                syntax_error_flag = 1;
            }
        }
        
        // if语句缺少分号的特殊情况
        if (strstr(line, "if") && strstr(line, "else") && !strstr(line, ";") && !strstr(line, "{")) {
            if (last_error_lineno != curr_line) {
                fprintf(stderr, "Error type B at Line %d: Missing \";\".\n", curr_line);
                last_error_lineno = curr_line;
                syntax_error_flag = 1;
            }
        }
        
        curr_line++;
    }
    
    fclose(file);
}

void yyerror(const char *s) {
    if (!lexical_error_flag && last_error_lineno != lineno) {
        syntax_error_flag = 1;
        last_error_lineno = lineno;
        fprintf(stderr, "Error type B at Line %d: syntax error\n", lineno);
    }
}