#include "globals.h"

int lexical_error_flag = 0;
int syntax_error_flag = 0;

char* copyString(const char* s) {
    if (!s) return NULL;
    char* t = (char*)malloc(strlen(s) + 1);
    if (t) strcpy(t, s);
    return t;
}

TreeNode* newNode(NodeKind kind, int lineno) {
    TreeNode* t = (TreeNode*)calloc(1, sizeof(TreeNode));
    t->nodekind = kind;
    t->lineno = lineno;
    return t;
}

void printTree(TreeNode* t, int indent) {
    if (!t) return;
    for (int i = 0; i < indent; ++i) printf("  ");
    switch (t->nodekind) {
        case ProgramK:         printf("Program (%d)\n", t->lineno); break;
        case ExtDefListK:      printf("ExtDefList (%d)\n", t->lineno); break;
        case ExtDefK:          printf("ExtDef (%d)\n", t->lineno); break;
        case SpecifierK:       printf("Specifier (%d)\n", t->lineno); break;
        case StructSpecifierK: printf("StructSpecifier (%d)\n", t->lineno); break;
        case OptTagK:          printf("OptTag (%d)\n", t->lineno); break;
        case TagK:             printf("Tag (%d)\n", t->lineno); break;
        case ExtDecListK:      printf("ExtDecList (%d)\n", t->lineno); break;
        case VarDecK:          printf("VarDec (%d)\n", t->lineno); break;
        case FunDecK:          printf("FunDec (%d)\n", t->lineno); break;
        case VarListK:         printf("VarList (%d)\n", t->lineno); break;
        case ParamDecK:        printf("ParamDec (%d)\n", t->lineno); break;
        case CompStK:          printf("CompSt (%d)\n", t->lineno); break;
        case DefListK:         printf("DefList (%d)\n", t->lineno); break;
        case DefK:             printf("Def (%d)\n", t->lineno); break;
        case DecListK:         printf("DecList (%d)\n", t->lineno); break;
        case DecK:             printf("Dec (%d)\n", t->lineno); break;
        case StmtListK:        printf("StmtList (%d)\n", t->lineno); break;
        case StmtK:            printf("Stmt (%d)\n", t->lineno); break;
        case ExpK:             printf("Exp (%d)\n", t->lineno); break;
        case ArgsK:            printf("Args (%d)\n", t->lineno); break;
        case IdK:              printf("ID: %s\n", t->name); break;
        case TypeK:            printf("TYPE: %s\n", t->name); break;
        case IntK:             printf("INT: %d\n", t->ival); break;
        case FloatK:           printf("FLOAT: %f\n", t->fval); break;
        default:               printf("Unknown\n"); break;
    }
    for (int i = 0; i < MAX_CHILDREN; ++i)
        if (t->child[i]) printTree(t->child[i], indent + 1);
    if (t->sibling) printTree(t->sibling, indent);
}