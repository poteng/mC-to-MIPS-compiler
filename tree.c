#include<tree.h>
#include<stdio.h>
#include<stdlib.h>

/* string values for ast node types, makes tree output more readable */
char *nodeNames_old[8] = {"program", "vardecl", "typeSpecfier", "assignStmt", "ifStmt", "exp", "integer", "identifier"};



char *nodeNames[65] = {"program", "varDecl", "typeSpecifier", "assignStmt", "var", 
	"decl", "declList", "funDecl", "formalDecl", "formalDeclList", "funBody", "localDeclList", "statementList", "statement", 
	"compoundStmt", "condStmt", "loopStmt", "returnStmt", "expression", "addExpr", "relop", "term", "addop", "factor", "mulop", 
	"funcCallExpr", "argList", "ID", "INTCONST", "CHARCONST", "STRCONST", "KWD_IF", "KWD_ELSE", "KWD_WHILE", "KWD_INT", "KWD_STRING", 
	"KWD_CHAR", "KWD_RETURN", "KWD_VOID", "OPER_ADD", "OPER_SUB", "OPER_MUL", "OPER_DIV", "OPER_LT", "OPER_GT", "OPER_GTE", "OPER_LTE", 
	"OPER_EQ", "OPER_NEQ", "OPER_ASGN", "LSQ_BRKT", "RSQ_BRKT", "LCRLY_BRKT", "RCRLY_BRKT", "LPAREN", "RPAREN", "COMMA", "SEMICLN", "AT", 
	"ILLEGAL_TOK", "ERROR", "TEST", "ERROR_COM", "ERROR_STR", "TEST2"
	};





tree *maketree(int kind) {
	tree *this = (tree *) malloc(sizeof(struct treenode));
	//printf("(maketree) creating node... nodekind = %d\n", kind);
	
	//if (kind > 64) {kind -= 230;}
	this->nodeKind = kind;
	this->numChildren = 0;
	return this;

}

tree *maketreeWithVal(int kind, int val) {
	tree *this = (tree *) malloc(sizeof(struct treenode));
	printf("(maketreeWithVal) creating node... nodekind = %d\n", kind);
	
	//if (kind > 64) {kind -= 230;}
	this->nodeKind = kind;
	this->numChildren = 0;
	
	//if (kind == 27)
	if (kind == 257) //ID
	{
		this->valStr = val;
	}
	else
	{
		this->val = val; 
	}
	
	
	return this;

}

tree *maketreeWithStr(int kind, char* val) {
	tree *this = (tree *) malloc(sizeof(struct treenode));
	printf("(maketreeWithStr) creating node... nodekind = %d\n", kind);
	
	//if (kind > 64) {kind -= 230;}
	this->nodeKind = kind;
	this->numChildren = 0;
	
	//if (kind == 27)
	if (kind == 257) //ID
	{
	this->valStr = val;
	
	}else{
	printf("ERRORRRRRRRRRRRRRRRRRRRRR\n");
	}
	
	
	return this;

}



void addChild(tree *parent, tree *child) {
	if (parent->numChildren == MAXCHILDREN) {
		printf("Cannot add child to parent node\n");
		exit(1);
	}
	nextAvailChild(parent) = child;
	parent->numChildren++;
}

void printAst(tree *node, int nestLevel) {
	//printf("begin printAST with nodeKind = %d\n", node->nodeKind);
	if (node == 0) {printf("IT\'S NULLLL!!!!\n\n");}
		if (node->nodeKind == 258) {	 //INTCONST
			//printf("int const  ");
			printf("%s   ", nodeNames[node->nodeKind - 230]);
			printf("<%d>\n", node->val);
		}		 
		else if (node->nodeKind == 257) { //ID
			//printf("id  ");
			printf("%s   ", nodeNames[node->nodeKind - 230]);
			printf("<%s>\n", node->valStr);
			//printf("<%d>\n", node->val);
		}
		//Seems like there are some problems with (node->nodeKind == KWD_INT) expression?
		else if (node->nodeKind == 264 || node->nodeKind == 266 || node->nodeKind == 268)
		{
			//printf("KWD  ");
			printf("%s\n", nodeNames[node->nodeKind - 230]);
		}
		else
		{
			//printf("else  ");
			if (node->nodeKind > 65)
			{
				//printf("WARMING nodekind > 65 with nodeKind = %d\n\n", node->nodeKind);
				printf("%s\n", nodeNames[node->nodeKind - 230]);
			}
			else
			{
				printf("%s\n", nodeNames[node->nodeKind]);
			}
			
			//printf("%d ",	node->nodeKind);
		}

	int i, j;

	for (i = 0; i < node->numChildren; i++)	 {
		for (j = 0; j < nestLevel; j++) 
			printf("   ");
		printAst(getChild(node, i), nestLevel + 1);
	}
}



/*
void printAst(tree *node, int nestLevel) {

	printf("%s\n", nodeNames[node->nodeKind]);

	int i, j;

	for (i = 0; i < node->numChildren; i++)	 {
		for (j = 0; j < nestLevel; j++) 
			printf("\t");
		printAst(getChild(node, i), nestLevel + 1);
	}
}
*/