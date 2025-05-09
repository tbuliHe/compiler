#ifndef _GLOBALS_H_
#define _GLOBALS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define MAX_CHILDREN 4

typedef enum { ProgramK, ExtDefListK, ExtDefK, SpecifierK, StructSpecifierK, OptTagK, TagK,
               ExtDecListK, VarDecK, FunDecK, VarListK, ParamDecK, CompStK, DefListK, DefK,
               DecListK, DecK, StmtListK, StmtK, ExpK, ArgsK, IdK, TypeK, IntK, FloatK } NodeKind;

typedef struct treeNode {
    NodeKind nodekind;
    int lineno;
    char *name; // For ID, TYPE, etc.
    int ival;
    float fval;
    struct treeNode *child[MAX_CHILDREN];
    struct treeNode *sibling;
} TreeNode;

// 全局变量
extern int lineno;
extern int lexical_error_flag;
extern int syntax_error_flag;

// 工具函数
char* copyString(const char* s);
TreeNode* newNode(NodeKind kind, int lineno);
void printTree(TreeNode* t, int indent);

#endif