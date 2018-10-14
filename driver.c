#include<y.tab.c>
#include<stdio.h>
#include<tree.h>
#include<strtab.h>

int main() {

    printf("Start.\n\n");
  if (!yyparse())
  {
    printf("Accept.\n\n");
	printAst(ast, 1);
    printf("Tree shown above.\n\n");
  }
  else
  {
    printf("Doesn't accept.\n\n");
    //printAst(ast, 1);
  }
    
  return 0;
}
