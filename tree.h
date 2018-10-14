#ifndef TREE_H
#define TREE_H

#define MAXCHILDREN 12
#define MAXARGUMENT 12

typedef struct treenode tree; 

/* tree node - you may want to add more fields */
struct treenode {
  int nodeKind;
  int numChildren;
  int val;
  char valChar;
  char* valStr;
  tree *parent;
  tree *children[MAXCHILDREN];
};

/* builds sub tree with zeor children  */
tree *maketree(int kind);

/* builds sub tree with leaf node */
tree *maketreeWithVal(int kind, int val);

void addChild(tree *parent, tree *child);

void printAst(tree *root, int nestLevel);

enum nodeTypes { program, varDecl, typeSpecifier, assignStmt, var, //0-4
	decl, declList, funDecl, formalDecl, formalDeclList, funBody, localDeclList, statementList, statement, //5-13
	compoundStmt, condStmt, loopStmt, returnStmt, expression, addExpr, relop, term, addop, factor, mulop, //14-24
	funcCallExpr, argList, ID, INTCONST, CHARCONST, STRCONST, KWD_IF, KWD_ELSE, KWD_WHILE, KWD_INT, KWD_STRING, //25-35
	KWD_CHAR, KWD_RETURN, KWD_VOID, OPER_ADD, OPER_SUB, OPER_MUL, OPER_DIV, OPER_LT, OPER_GT, OPER_GTE, OPER_LTE, //36-46
	OPER_EQ, OPER_NEQ, OPER_ASGN, LSQ_BRKT, RSQ_BRKT, LCRLY_BRKT, RCRLY_BRKT, LPAREN, RPAREN, COMMA, SEMICLN, AT, //47-58
	ILLEGAL_TOK, ERROR, TEST, ERROR_COM, ERROR_STR, TEST2 //59-64
	};

/* tree manipulation macros */ 
/* if you are writing your compiler in C, you would want to have a large collection of these */

#define nextAvailChild(node) node->children[node->numChildren] 
#define getChild(node, index) node->children[index]

#endif
