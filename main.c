#include "globals.h"
#include <stdio.h>

extern int yyparse(void);
extern FILE* yyin;
extern TreeNode* syntaxTree;
extern int lexical_error_flag, syntax_error_flag;

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <sourcefile>\n", argv[0]);
        return 1;
    }
    FILE* f = fopen(argv[1], "r");
    if (!f) {
        fprintf(stderr, "Cannot open file %s\n", argv[1]);
        return 1;
    }
    yyin = f;
    yyparse();
    fclose(f);

    if (!lexical_error_flag && !syntax_error_flag && syntaxTree) {
        printTree(syntaxTree, 0);
    }
    return 0;
}