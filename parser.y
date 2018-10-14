%{
#include<stdio.h>
#include<tree.h>
#include<strtab.h>


int yylineno;
extern char * yytext;

int scopeLevel = 10;
int ErrorFlag = 0;


tree *ast;	/* pointer to AST root */

%}

%union 
{
  int value;
  struct treenode *node;
  char *strval;
}



/* major stuff */
%token <strval> ID
%token <value> INTCONST
%token <value> CHARCONST
%token <value> STRCONST

/* keywords */
%token <value> KWD_IF
%token <value> KWD_ELSE
%token <value> KWD_WHILE
%token <value> KWD_INT
%token <value> KWD_STRING
%token <value> KWD_CHAR
%token <value> KWD_RETURN
%token <value> KWD_VOID

/* operators */
%token <value> OPER_ADD
%token <value> OPER_SUB
%token <value> OPER_MUL
%token <value> OPER_DIV
%token <value> OPER_LT
%token <value> OPER_GT
%token <value> OPER_GTE
%token <value> OPER_LTE
%token <value> OPER_EQ
%token <value> OPER_NEQ
%token <value> OPER_ASGN

/* brackets & parens */
%token <value> LSQ_BRKT
%token <value> RSQ_BRKT
%token <value> LCRLY_BRKT
%token <value> RCRLY_BRKT
%token <value> LPAREN
%token <value> RPAREN

/* punctuation */
%token <value> COMMA
%token <value> SEMICLN
%token <value> AT

%token <value> ILLEGAL_TOK
%token <value> ERROR

%token <value> TEST
%token <value> ERROR_COM
%token <value> ERROR_STR
%token <value> TEST2

%type <node> program varDecl typeSpecifier assignStmt var 

%type <node> decl declList funDecl formalDecl formalDeclList funBody localDeclList statementList statement compoundStmt condStmt loopStmt 
%type <node> returnStmt expression addExpr relop term addop factor mulop funcCallExpr argList


%start program

%%

program		: declList
			{
				tree *progNode = maketree(program);
				addChild(progNode, $1);
				ast = progNode;
			}
			;

declList	: decl
			{
				tree *declNode = maketree(declList);
				addChild(declNode, $1);
				$$ = declNode;
			}
			| declList decl
			{
				/*	tree *declNode = maketree(declList);
				addChild(declNode, $1);
				addChild(declNode, $2);
				$$ = declNode;*/


				addChild($1, $2);
				$$ = $1;
			}
			;

decl		: varDecl
			{
				tree *declNode = maketree(decl);
				addChild(declNode, $1);
				$$ = declNode;
			}
			| funDecl
			{
				tree *declNode = maketree(decl);
				addChild(declNode, $1);
				$$ = declNode;
			}
	   ;

varDecl		: typeSpecifier ID LSQ_BRKT INTCONST RSQ_BRKT SEMICLN
			{
				tree *varDeclNode = maketree(varDecl);
					
				addChild(varDeclNode, $1);
		
				/* check for multiply declared variables. */
				if ( !ST_lookup($2, 1) )
				{
					ST_insert($2, $1->children[0]->nodeKind, $4, scopeLevel);
					//printf("nodekind is %d\n", $1->nodeKind);
				}
				else
				{
					printf("\n\nERROR. \'%s\' has already been declared.  line %d\n\n\n", $2, yylineno);
					ErrorFlag = 1;
				}
		
				addChild(varDeclNode, maketreeWithVal(ID, $2));
		
				addChild(varDeclNode, maketree(LSQ_BRKT));
		
				addChild(varDeclNode, maketreeWithVal(INTCONST, $4));
		
				addChild(varDeclNode, maketree(RSQ_BRKT));
				addChild(varDeclNode, maketree(SEMICLN));
			
				$$ = varDeclNode;
			}
			| typeSpecifier ID SEMICLN
			{
				tree *varDeclNode = maketree(varDecl);
				addChild(varDeclNode, $1);
			
				if ( !ST_lookup($2, 1) )
				{
					ST_insert($2, $1->children[0]->nodeKind, 0, scopeLevel);
					//printf("nodekind is %d\n", $1->nodeKind);
				}
				else
				{
					printf("\n\nERROR. \'%s\' has already been declared.  line %d\n\n\n", $2, yylineno);
					ErrorFlag = 1;
				}
			
				addChild(varDeclNode, maketreeWithVal(ID, $2));
			
				addChild(varDeclNode, maketree(SEMICLN));
				$$ = varDeclNode;
			}
			;  

		
typeSpecifier	: KWD_INT 
			{	   
				tree *typeSpecifierNode = maketree(typeSpecifier);
			
				addChild(typeSpecifierNode, maketree(KWD_INT));
			
				$$ = typeSpecifierNode;
			
			}
			| KWD_CHAR
			{	   
				tree *typeSpecifierNode = maketree(typeSpecifier);
			
				addChild(typeSpecifierNode, maketree(KWD_CHAR));
			
				$$ = typeSpecifierNode;
			
			}
			| KWD_VOID
			{	   
				tree *typeSpecifierNode = maketree(typeSpecifier);
			
				addChild(typeSpecifierNode, maketree(KWD_VOID));
			
				$$ = typeSpecifierNode;
			}
			;
	   
	   
	   
	   
funDecl		: typeSpecifier ID LPAREN 
			{
				scopeLevel++;
				printf("Scope Level =  %d\n", scopeLevel);
			}
			formalDeclList RPAREN 
			{
				scopeLevel--;
				printf("Scope Level =  %d\n", scopeLevel);
			}
			funBody 
			{	
				//ST_insert($2, $1->children[0]->nodeKind, 0, scopeLevel);
				
				if ( !ST_lookup($2, 1) )
				{
					ST_insert($2, $1->children[0]->nodeKind, 0, scopeLevel);
					//printf("nodekind is %d\n", $1->nodeKind);
				}
				else
				{
					printf("\n\nERROR. \'%s\' has already been declared.  line %d\n\n\n", $2, yylineno);
					ErrorFlag = 1;
				}
				
				tree *funDeclNode = maketree(funDecl);
				addChild(funDeclNode, $1);
				
				/* record argument information for this function */
				record_argument($2, $5);
				
				addChild(funDeclNode, maketreeWithVal(ID, $2));
		
				addChild(funDeclNode, maketree(LPAREN));
		
				addChild(funDeclNode, $5);
				
				addChild(funDeclNode, maketree(RPAREN));
				
				addChild(funDeclNode, $8);
				
				$$ = funDeclNode;
				
			}
			| typeSpecifier ID LPAREN RPAREN funBody
			{
				tree *funDeclNode = maketree(funDecl);
				addChild(funDeclNode, $1);
				
				//ST_insert($2, $1->children[0]->nodeKind, 0, scopeLevel);
				if ( !ST_lookup($2, 1) )
				{
					ST_insert($2, $1->children[0]->nodeKind, 0, scopeLevel);
					//printf("nodekind is %d\n", $1->nodeKind);
				}
				else
				{
					printf("\n\nERROR. \'%s\' has already been declared.  line %d\n\n\n", $2, yylineno);
					ErrorFlag = 1;
				}
				addChild(funDeclNode, maketreeWithVal(ID, $2));
				
						addChild(funDeclNode, maketree(LPAREN));
						addChild(funDeclNode, maketree(RPAREN));
				
				addChild(funDeclNode, $5);
				
				$$ = funDeclNode;
			}
			;
	
formalDeclList	: formalDecl
			{	   
				tree *formalDeclListNode = maketree(formalDeclList);
						
				addChild(formalDeclListNode, $1);
				
				$$ = formalDeclListNode;
			}
			| formalDeclList COMMA formalDecl
			{	   
			/*	tree *formalDeclListNode = maketree(formalDeclList);
						
				addChild(formalDeclListNode, $1);
				
						addChild(formalDeclListNode, maketree(COMMA));
				
				addChild(formalDeclListNode, $3);
				
				$$ = formalDeclListNode;*/
				
		
				addChild($1, maketree(COMMA));
				addChild($1, $3);
				

				
				$$ = $1;
			}
			;
	
formalDecl	: typeSpecifier ID
			{	   
				tree *formalDeclNode = maketree(formalDecl);
						
				addChild(formalDeclNode, $1);
				/* function argument names are treated scopeLevel = 11 */
				ST_insert($2, $1->children[0]->nodeKind, 0, 11);
				addChild(formalDeclNode, maketreeWithVal(ID, $2));
				
				$$ = formalDeclNode;
			}
			| typeSpecifier ID LSQ_BRKT RSQ_BRKT
			{	   
				tree *formalDeclNode = maketree(formalDecl);
						
				addChild(formalDeclNode, $1);
				
				ST_insert($2, $1->children[0]->nodeKind, -1, 11); /* size in argument ID is -1 */
				addChild(formalDeclNode, maketreeWithVal(ID, $2));
				
				addChild(formalDeclNode, maketree(LSQ_BRKT));
				addChild(formalDeclNode, maketree(RSQ_BRKT));
				
				$$ = formalDeclNode;
			}
			;


funBody		: LCRLY_BRKT
			{
				scopeLevel+=2;
				printf("Scope Level =  %d\n", scopeLevel);
			}
			localDeclList statementList RCRLY_BRKT
			{	   
				tree *funBodyNode = maketree(funBody);
						
				addChild(funBodyNode, maketree(LCRLY_BRKT));
				addChild(funBodyNode, $3);
				addChild(funBodyNode, $4);
				addChild(funBodyNode, maketree(RCRLY_BRKT));
				
				scopeLevel-=2;
				printf("Scope Level =  %d\n", scopeLevel);
				display_table();
				clean_local_argument(); /* clean local argument declarations (scopeLevel == 11) */
				
				$$ = funBodyNode;
			}
			;

localDeclList	: 
				{
					tree *localDeclListNode = maketree(localDeclList);

					$$ = localDeclListNode;
				}
				| varDecl localDeclList
				{	   
					tree *localDeclListNode = maketree(localDeclList);
							
					addChild(localDeclListNode, $1);
					addChild(localDeclListNode, $2);

					$$ = localDeclListNode;
				}
				;

statementList	: 
				{
					tree *localDeclListNode = maketree(statementList);

					$$ = localDeclListNode;
				}
				| statementList statement
				{	   
				/*	tree *statementListNode = maketree(statementList);
							
					addChild(statementListNode, $1);
					addChild(statementListNode, $2);
					
					$$ = statementListNode;*/

							
					addChild($1, $2);

					$$ = $1;
				}
				;
		
statement	: compoundStmt
			{	   
				tree *statementNode = maketree(statement);
						
				addChild(statementNode, $1);
				
				$$ = statementNode;
			}
			| assignStmt
			{	   
				tree *statementNode = maketree(statement);
						
				addChild(statementNode, $1);
				
				$$ = statementNode;
			}
			| condStmt
			{	   
				tree *statementNode = maketree(statement);
						
				addChild(statementNode, $1);
				
				$$ = statementNode;
			}
			| loopStmt
			{	   
				tree *statementNode = maketree(statement);
						
				addChild(statementNode, $1);
				
				$$ = statementNode;
			}
			| returnStmt
			{	   
				tree *statementNode = maketree(statement);
						
				addChild(statementNode, $1);
				
				$$ = statementNode;
			}
			;	
		

		
		
compoundStmt: LCRLY_BRKT statementList RCRLY_BRKT
			{	   
				tree *compoundStmtNode = maketree(compoundStmt);
			
				addChild(compoundStmtNode, maketree(LCRLY_BRKT));
								
				addChild(compoundStmtNode, $2);
						
				addChild(compoundStmtNode, maketree(RCRLY_BRKT));
			
				$$ = compoundStmtNode;
			}
			;		
		

		
		
assignStmt	: var OPER_ASGN expression SEMICLN 
			{
				tree *assignNode = maketree(assignStmt);
				addChild(assignNode, $1);

				addChild(assignNode, maketree(OPER_ASGN));

				addChild(assignNode, $3);

				addChild(assignNode, maketree(SEMICLN));
				
				/* check if RHS is the same type as LHS */
				if (!check_assign_type($1, $3))
				{
					printf("\n\nERROR.	Incompatible assignment.  line %d\n\n\n", yylineno);
					ErrorFlag = 1;
				}
				
				$$ = assignNode;
			}
			| expression SEMICLN
			{
				tree *assignNode = maketree(assignStmt);

				addChild(assignNode, $1);

				addChild(assignNode, maketree(SEMICLN));

				$$ = assignNode;
			}
			;
		
condStmt	: KWD_IF LPAREN expression RPAREN statement
			{	   
				tree *condStmtNode = maketree(condStmt);

				addChild(condStmtNode, maketree(KWD_IF));
				addChild(condStmtNode, maketree(LPAREN));

				addChild(condStmtNode, $3);

				addChild(condStmtNode, maketree(RPAREN));

				addChild(condStmtNode, $5);

				$$ = condStmtNode;
			}
			| KWD_IF LPAREN expression RPAREN statement KWD_ELSE statement
			{	   
				tree *condStmtNode = maketree(condStmt);

				addChild(condStmtNode, maketree(KWD_IF));
				addChild(condStmtNode, maketree(LPAREN));

				addChild(condStmtNode, $3);

				addChild(condStmtNode, maketree(RPAREN));

				addChild(condStmtNode, $5);

				addChild(condStmtNode, maketree(KWD_ELSE));

				addChild(condStmtNode, $7);

				$$ = condStmtNode;
			}
			;		
		
		
loopStmt	: KWD_WHILE LPAREN expression RPAREN statement
			{	   
				tree *loopStmtNode = maketree(loopStmt);
						
				addChild(loopStmtNode, maketree(KWD_WHILE));
				addChild(loopStmtNode, maketree(LPAREN));
				
				addChild(loopStmtNode, $3);
				
				addChild(loopStmtNode, maketree(RPAREN));
				
				addChild(loopStmtNode, $5);
				
				$$ = loopStmtNode;
			}
			;
		
returnStmt	: KWD_RETURN SEMICLN
			{	   
				tree *returnStmtNode = maketree(returnStmt);
						
				addChild(returnStmtNode, maketree(KWD_RETURN));
				addChild(returnStmtNode, maketree(SEMICLN));
				
				$$ = returnStmtNode;
			}
			| KWD_RETURN expression SEMICLN
			{	   
				tree *returnStmtNode = maketree(returnStmt);
						
				addChild(returnStmtNode, maketree(KWD_RETURN));
				
				addChild(returnStmtNode, $2);
				
				addChild(returnStmtNode, maketree(SEMICLN));
				
				$$ = returnStmtNode;
			}
			;
		
var			: ID
			{	   
				tree *varNode = maketree(var);
				/* check if it's declared*/
				if (!ST_lookup($1, 0) && !ST_lookup($1, 1) && !ST_lookup($1, 11))
				{
					printf("\n\nERROR. \'%s\' is undefined.	 line %d\n\n\n", $1, yylineno);
					ErrorFlag = 1;
				};
				addChild(varNode, maketreeWithVal(ID, $1));
				
				/* check if ID is actually an array */
				if (!check_array($1, 0))
				{
					printf("\n\nERROR. Out of array boundary for \'%s\'.	 line %d\n\n\n", $1, yylineno);
					ErrorFlag = 1;
				}
				
				$$ = varNode;
			}
			| ID LSQ_BRKT addExpr RSQ_BRKT
			{	   
				tree *varNode = maketree(var);
				/* check if it's declared*/
				if (!ST_lookup($1, 0) && !ST_lookup($1, 1) && !ST_lookup($1, 11))
				{
					printf("\n\nERROR. \'%s\' is undefined.	 line %d\n\n\n", $1, yylineno);
					ErrorFlag = 1;
				};
				
				/* check if the index is integer type */
				if (!type_addExpr($3))
				{
					printf("\n\nERROR. \'%s[]\' has non-integer type index.	 line %d\n\n\n", $1, yylineno);
					ErrorFlag = 1;
				}
		
				/* check if the index is out of boundary */
				if (!check_array($1, $3))
				{
					printf("\n\nERROR. Out of array boundary for \'%s\'.	 line %d\n\n\n", $1, yylineno);
					ErrorFlag = 1;
				}
		
				addChild(varNode, maketreeWithVal(ID, $1));
		
				addChild(varNode, maketree(LSQ_BRKT));
				addChild(varNode, $3);
				addChild(varNode, maketree(RSQ_BRKT));
		
				$$ = varNode;
			}
			;
		
expression	: addExpr
			{	   
				tree *expressionNode = maketree(expression);
						
				addChild(expressionNode, $1);
				
				$$ = expressionNode;
			}
			| expression relop addExpr
			{	   
				tree *expressionNode = maketree(expression);
						
				addChild(expressionNode, $1);
				addChild(expressionNode, $2);
				addChild(expressionNode, $3);
				
				$$ = expressionNode;
			}
			;
		
		
   
		
relop		: OPER_LTE
			{	   
				tree *relopNode = maketree(relop);
				
				addChild(relopNode, maketree(OPER_LTE));
				
				$$ = relopNode;
			}
			| OPER_LT
			{	   
				tree *relopNode = maketree(relop);
			
				addChild(relopNode, maketree(OPER_LT));
			
				$$ = relopNode;
			}
			| OPER_GT
			{	   
				tree *relopNode = maketree(relop);
				
				addChild(relopNode, maketree(OPER_GT));
				
				$$ = relopNode;
			}
			| OPER_GTE
			{	   
				tree *relopNode = maketree(relop);
				
				addChild(relopNode, maketree(OPER_GTE));
				
				$$ = relopNode;
			}
			| OPER_EQ
			{	   
				tree *relopNode = maketree(relop);
				
				addChild(relopNode, maketree(OPER_EQ));
				
				$$ = relopNode;
			}
			| OPER_NEQ
			{	   
				tree *relopNode = maketree(relop);
				
				addChild(relopNode, maketree(OPER_NEQ));
				
				$$ = relopNode;
			}
			;

addExpr		: term
			{	   
				tree *addExprNode = maketree(addExpr);
						
				addChild(addExprNode, $1);
				
				
				$$ = addExprNode;
			}
			| addExpr addop term
			{	   
			/*	tree *addExprNode = maketree(addExpr);
						
				addChild(addExprNode, $1);
				addChild(addExprNode, $2);
				addChild(addExprNode, $3);
				
				$$ = addExprNode;*/
				

				addChild($1, $2);
				addChild($1, $3);
				
				int sum;
				
				if (check_constant_folding($1))
				{
					sum = constant_folding($1);
					$1->numChildren = 1;
					$1->children[0]->children[0]->children[0]->val = sum;
				}
				
				
				$$ = $1;
			}
			;

addop		: OPER_ADD
			{	   
				tree *addopNode = maketree(addop);
				
				addChild(addopNode, maketree(OPER_ADD));
				
				$$ = addopNode;
			}
			| OPER_SUB
			{	   
				tree *addopNode = maketree(addop);
				
				addChild(addopNode, maketree(OPER_SUB));
				
				$$ = addopNode;
			}
			;
		
		
term		: factor
			{	   
				tree *termNode = maketree(term);
						
				addChild(termNode, $1);
				
				$$ = termNode;
			}
			| term mulop factor
			{	   
			/*	tree *termNode = maketree(term);
						
				addChild(termNode, $1);
				addChild(termNode, $2);
				addChild(termNode, $3);
				
				$$ = termNode;*/
				
				addChild($1, $2);
				addChild($1, $3);
				
				int product;
				
				if (check_constant_folding_mul($1))
				{
					product = constant_folding_mul($1);
					$1->numChildren = 1;
					$1->children[0]->children[0]->val = product;
				}
				
				$$ = $1;
				
			}
			;
		
		
mulop		: OPER_MUL
			{	   
				tree *mulopNode = maketree(mulop);
				
				addChild(mulopNode, maketree(OPER_MUL));
				
				$$ = mulopNode;
			}
			| OPER_DIV
			{	   
				tree *mulopNode = maketree(mulop);
				
				addChild(mulopNode, maketree(OPER_DIV));
				
				$$ = mulopNode;
			}
			;
		

factor		: LPAREN expression RPAREN
			{	   
				tree *factorNode = maketree(factor);
						
				addChild(factorNode, maketree(LPAREN));
				
				addChild(factorNode, $2);
				
				addChild(factorNode, maketree(RPAREN));
				
				$$ = factorNode;
			}
			| var
			{	   
				tree *factorNode = maketree(factor);

				addChild(factorNode, $1);

				$$ = factorNode;
			}
			| funcCallExpr
			{	   
				tree *factorNode = maketree(factor);

				addChild(factorNode, $1);

				$$ = factorNode;
			}
			| INTCONST
			{	   
				tree *factorNode = maketree(factor);
				addChild(factorNode, maketreeWithVal(INTCONST, $1));
				
				$$ = factorNode;
			}
			| CHARCONST
			{	   
				tree *factorNode = maketree(factor);
				
				addChild(factorNode, maketree(CHARCONST));
				
				$$ = factorNode;
			}
			| STRCONST
			{	   
				tree *factorNode = maketree(factor);
				
				addChild(factorNode, maketree(STRCONST));
				
				$$ = factorNode;
			}
			;		

funcCallExpr: ID LPAREN argList RPAREN 
			{	   
				tree *funcCallExprNode = maketree(funcCallExpr);
				/* check if it's declared*/
				if (strcmp($1, "output") == 0)
				{
					printf("\n\nDDDDDEEEEEEETTTTTTTTEEEEEEEEEE\n\n");
				}
				else 
				{
					if (!ST_lookup($1, 0) && !ST_lookup($1, 1))
					{
						printf("\n\nERROR. \'%s\' is undefined.	 line %d\n\n\n", $1, yylineno);
						ErrorFlag = 1;
					}
					check_argList($1, $3);
				}
				
				addChild(funcCallExprNode, maketreeWithVal(ID, $1));
		
				addChild(funcCallExprNode, maketree(LPAREN));
		
				addChild(funcCallExprNode, $3);
		
				addChild(funcCallExprNode, maketree(RPAREN));
				
				$$ = funcCallExprNode;
			}
			| ID LPAREN RPAREN 
			{	   
				tree *funcCallExprNode = maketree(funcCallExpr);
				/* check if it's declared*/
				if (!ST_lookup($1, 0) && !ST_lookup($1, 1))
				{
					display_table;
					printf("\n\n look up = %d, %d \n\n", ST_lookup($1, 0), ST_lookup($1, 1));
					printf("\n\nERROR. \'%s\' is undefined.	fdgdf line %d\n\n\n", $1, yylineno);
					ErrorFlag = 1;
				};
				
				
				
				addChild(funcCallExprNode, maketreeWithVal(ID, $1));
		
				addChild(funcCallExprNode, maketree(LPAREN));
				addChild(funcCallExprNode, maketree(RPAREN));
				check_argList($1, funcCallExprNode->children[1]);
				
				$$ = funcCallExprNode;
			}
			;		

argList		: expression
			{	   
				tree *argListNode = maketree(argList);
						
				addChild(argListNode, $1);
				
				$$ = argListNode;
			}
			| argList COMMA expression
			{	   
			/*	tree *argListNode = maketree(argList);
						
				addChild(argListNode, $1);
				
						addChild(argListNode, maketree(COMMA));
				
				addChild(argListNode, $3);
				
				$$ = argListNode;*/
				

				addChild($1, maketree(COMMA));
				
				addChild($1, $3);
				
				$$ = $1;
			}
			;		

		

%%



int hash (char* ptr_str)
{
	int sum = 0;
	int i;
	for (i = 0; i< strlen(ptr_str); i++)
	{
		//printf("%c\n", ptr_str[i]);
		sum += ptr_str[i];
	}
	//printf("hash returns for %s: %d\n", ptr_str, sum);
	return sum%MAXHASH;
}


//type is like KWD_INT...
int ST_insert(char* name, int type, int sizeArray, int scope) //
{
	int indexHash = hash(name);
	printf("(ST_insert) inserting: %s  type=%d	sizeArray=%d  scope=%d\n", name, type, sizeArray, scope);

	if (symbolTable[indexHash].name == 0)	//slot is empty
	{
		printf("slot is empty\n");
		symbolTable[indexHash].name = name;
		symbolTable[indexHash].type = type;
		symbolTable[indexHash].sizeArray = sizeArray;
		symbolTable[indexHash].scope = scope;
		
		printf("(ST_insert) insert complete: %s  type=%d  sizeArray=%d  scope=%d\n", name, type, sizeArray, symbolTable[indexHash].scope);
	}
	else									//slot is occupied
	{
		//node_t * head = NULL;
		//head = malloc(sizeof(node_t));

		printf("slot is occupied. add as a chain node.\n");

		struct tableNode* ptr_this;
		ptr_this = &symbolTable[indexHash];

		//find the end of the chain
		while (ptr_this->ptrNext != 0)
		{
			ptr_this = ptr_this->ptrNext;
		}

		ptr_this->ptrNext = malloc(sizeof(struct tableNode));
		ptr_this->ptrNext->name = name;
		ptr_this->ptrNext->type = type;
		ptr_this->ptrNext->sizeArray = sizeArray;
		ptr_this->ptrNext->scope = scope;
		ptr_this->ptrNext->ptrNext = 0;
		
		printf("(ST_insert) insert complete: %s  type=%d  sizeArray= %d  scope=%d\n", name, type, sizeArray, ptr_this->ptrNext->scope);
	}
	return 0;
}


//check if name is in the symbol table, and return 0 or 1.
//for finding same name global/local variables
//scope = 0 global, scope = 1 local ( == scopeLevel), scope = 11 local (argument variable name)
int ST_lookup(char* name, int scope) {
	int indexHash = hash(name);
	//printf("looking up: %s\n", name);

	if (symbolTable[indexHash].name == 0)	//no such a hash value
	{
		//printf("the string is not in the table.\n");
		return 0;
	}
	else
	{
		//printf("the string might be in the table.\n");

		struct tableNode* ptr_this;
		ptr_this = &symbolTable[indexHash];

		//find in the chain
		while (ptr_this != 0)	//go through the whole chain
		{
			//printf("compare %s with %s\n", ptr_this->name, name);
			//check the same name variables only have same local scope or global scope
			if ( scope == 0 && strcmp( ptr_this->name, name ) == 0 && ptr_this->scope == 10 )
			{
				printf("the string is in the table. (global)\n");
				return ptr_this;
			}
			else if ( scope == 0 && strcmp( ptr_this->name, name ) == 0 && ptr_this->scope != 10 )
			{
				printf("the string is in the table but is not global.\n");
			}
			else if ( scope == 1 && strcmp( ptr_this->name, name ) == 0 && ptr_this->scope == scopeLevel )
			{
				printf("the string is in the table. (local)\n");
				return ptr_this;
			}
			else if ( scope == 1 && strcmp( ptr_this->name, name ) == 0 && ptr_this->scope != scopeLevel )
			{
				printf("the string is in the table but with different scopeLevel.\n");
			}
			else if ( scope == 11 && strcmp( ptr_this->name, name ) == 0 && ptr_this->scope == 11 )
			{
				printf("the string is in the table. (scopeLevel == 11)\n");
				return ptr_this;
			}
			else if ( scope == 11 && strcmp( ptr_this->name, name ) == 0 && ptr_this->scope != 11 )
			{
				printf("the string is in the table, but not an argument variable. (scopeLevel != 11)\n");
			}
			else
			{
				printf("\nNot found for scope argument. scope = %d, scopeLevel = %d\n\n", scope, scopeLevel);
			}
			ptr_this = ptr_this->ptrNext;
		}
		//printf("the string %s is not in the table.\n", name);
		return 0;
	}
	printf("ERRORRRRRRRRRR\n");
	ErrorFlag = 1;
}






void clean_local_argument()
{
	int i, j;
	struct tableNode* ptr_this;

	for (i = 0; i < MAXHASH; i++)	//go through all slots
	{
		//printf("i = %d\n", i);

			
			if (symbolTable[i].name != 0)	//has name. not a empty slot.
			{
				if (symbolTable[i].scope >= 11)
				{
					printf("Cleaning this: %d. %s\t", i, symbolTable[i].name);
					printf("%d\t", symbolTable[i].type);
					printf("%d\t", symbolTable[i].sizeArray);
					printf("%d\t\n", symbolTable[i].scope);
					
					symbolTable[i].name = 0;
					symbolTable[i].type = 0;
					symbolTable[i].sizeArray = 0;
					symbolTable[i].scope = 0;
					symbolTable[i].numArgument = 0;
					//symbolTable[i].typeArgument = 0;
					for (j = 0; j <symbolTable[i].numArgument; j++)
					{
						symbolTable[i].typeArgument[j] = 0;
					}
					symbolTable[i].ptrNext = 0;
					
				}
			}
			
			if (symbolTable[i].ptrNext != 0)  //has chained nodes
			{
				if (symbolTable[i].name != 0)	//has name. not a empty slot.
				{
					if (symbolTable[i].ptrNext->scope >= 11)
					{
						printf("Cleaning this: %d. %s\t", i, symbolTable[i].ptrNext->name);
						printf("%d\t", symbolTable[i].ptrNext->type);
						printf("%d\t", symbolTable[i].ptrNext->sizeArray);
						printf("%d\t\n", symbolTable[i].ptrNext->scope);
						
						symbolTable[i].ptrNext->name = 0;
						symbolTable[i].ptrNext->type = 0;
						symbolTable[i].ptrNext->sizeArray = 0;
						symbolTable[i].ptrNext->scope = 0;
						symbolTable[i].ptrNext->numArgument = 0;
						//symbolTable[i].typeArgument = 0;
						for (j = 0; j <symbolTable[i].ptrNext->numArgument; j++)
						{
							symbolTable[i].ptrNext->typeArgument[j] = 0;
						}
						symbolTable[i].ptrNext = 0;
						
					}
				}
				
			printf("nothing\n");
			}
	}
	return;
}





void display_table()
{
	int i;
	struct tableNode* ptr_this;

	for (i = 0; i < MAXHASH; i++)	//go through all slots
	{
		ptr_this = symbolTable[i].ptrNext;
		if (symbolTable[i].ptrNext == 0)	//doesn't have chained nodes
		{
			if (symbolTable[i].name != 0)	//has name. not a empty slot.
			{
				printf("%d. %s\t", i, symbolTable[i].name);
				printf("%d\t", symbolTable[i].type);
				printf("%d\t", symbolTable[i].sizeArray);
				printf("%d\t\n", symbolTable[i].scope);
			}

		}
		else	//has chained nodes
		{
			
			printf("%d. %s\t", i, symbolTable[i].name);
			printf("%d\t", symbolTable[i].type);
			printf("%d\t", symbolTable[i].sizeArray);
			printf("%d\t\n", symbolTable[i].scope);

			ptr_this = symbolTable[i].ptrNext;
			//display all chained nodes
			while (ptr_this != 0)
			{
				printf("-> %s\t", ptr_this->name);
				printf("%d\t", ptr_this->type);
				printf("%d\t", ptr_this->sizeArray);
				printf("%d\t", ptr_this->scope);
				ptr_this = ptr_this->ptrNext;
			}
		printf("\n");
		}
	}
	printf("\n");
	return;
}

int check_constant_folding(tree* nodeAddExpr)
{
	if (nodeAddExpr->nodeKind == 19)	//check for the type of 'addExpr' node is correct.
	{
		printf("(constant_folding) Correct. numChildren: %d\n", nodeAddExpr->numChildren);
		int i = 0;
		for (i = 0; i < nodeAddExpr->numChildren; i++)
		{
			if (nodeAddExpr->children[i]->nodeKind == 21)	//check all term nodes
			{
				if (nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 258)  //INTCONST
				{}
				else
				{
					printf("(constant_folding) At least one leaf node isn't INTCONST. i = %d\n", i);
					return 0;
				}
			}
			else if (nodeAddExpr->children[i]->nodeKind == 22) //addop
			{
			}
			else if (nodeAddExpr->children[i]->children[0]->nodeKind == 4) //var
			{
				printf("var involved.\n\n\n");
				return 0;
			}
			else
			{
				printf("????\n\n\n");
			}
		}
		printf("(check_constant_folding) Good for constant folding.\n");
		return 1;
	}
	else
	{
		printf("????\n\n\n");
		return 0;
	}
}

//term 21 addop 22 var 4 OPER_ADD 269 OPER_SUB 270
int constant_folding(tree* nodeAddExpr)
{
	if (nodeAddExpr->nodeKind == 19)	//check for the type of 'addExpr' node is correct.
	{
		printf("\n(constant_folding) Correct. numChildren: %d\n", nodeAddExpr->numChildren);
		
		int sum = 0;
		int sign = 0;
		int i = 0;
		for (i = 0; i < nodeAddExpr->numChildren; i++)
		{
			if (nodeAddExpr->children[i]->nodeKind == 21)	//check all term nodes
			{
				if (nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 258)  //INTCONST
				{
					printf("Adding leaf node with value %d.\n", nodeAddExpr->children[i]->children[0]->children[0]->val);
					if (sign == 0 || sign == 1)
					{
						sum += nodeAddExpr->children[i]->children[0]->children[0]->val;
					}
					else if (sign == - 1)
					{
						sum -= nodeAddExpr->children[i]->children[0]->children[0]->val;
					}
				}
				else
				{
					printf("(constant_folding) At least one leaf node isn't INTCONST. i = %d\n\n", i);
					return 0;
				}
			}
			else if (nodeAddExpr->children[i]->nodeKind == 22) //addop
			{
				if (nodeAddExpr->children[i]->children[0]->nodeKind == 269) //OPER_ADD
				{
					printf("add sign\n");
					sign = 1;
				}
				else
				{
					printf("sub sign\n");
					sign = -1;
				}	
			}
			else if (nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 4) //var
			{
				printf("var involved.\n\n\n");
			}
			else
			{
				printf("????\n\n\n");
			}
		}
		printf("(constant_folding) final result: %d\n" , sum);
		return sum;
	}
	else
	{
		printf("????\n\n\n");
		return 0;
	}
}




//term 21 addop 22 factor 23 mulop 24 var 4 OPER_ADD 269 OPER_SUB 270 OPER_MUL 271 OPER_DIV 272
int check_constant_folding_mul(tree* nodeTerm)
{
	if (nodeTerm->nodeKind == 21)	//check for the type of 'addExpr' node is correct.
	{
		printf("(check_constant_folding_mul) Correct. numChildren: %d\n", nodeTerm->numChildren);
		
		int sum = 0;
		int sign = 0;
		int i = 0;
		for (i = 0; i < nodeTerm->numChildren; i++)
		{
			if (nodeTerm->children[i]->nodeKind == 23)	//check all term nodes
			{
				if (nodeTerm->children[i]->children[0]->nodeKind == 258)  //INTCONST
				{
					if (sign == 0 || sign == 1)
					{
					}
					else if (sign == - 1)
					{
						if (nodeTerm->children[i]->children[0]->val == 0)
						{
							printf("\n\nERROR. Divide by 0. \n\n");
							ErrorFlag = 1;
							return 0;
						}
					}
				}
				else
				{
					printf("(check_constant_folding_mul) At least one leaf node isn't INTCONST. i = %d\n\n", i);
					return 0;
				}
			}
			else if (nodeTerm->children[i]->nodeKind == 24) //mulop
			{
			}
			else if (nodeTerm->children[i]->children[0]->nodeKind == 4) //var
			{
			}
			else
			{
				printf("????\n\n\n");
			}
		}
		printf("(check_constant_folding_mul) Good for constant folding.\n");
		return 1;
	}
	else
	{
		printf("????\n\n\n");
		return 0;
	}
}



//term 21 addop 22 factor 23 mulop 24 var 4 OPER_ADD 269 OPER_SUB 270 OPER_MUL 271 OPER_DIV 272
int constant_folding_mul(tree* nodeTerm)
{
	if (nodeTerm->nodeKind == 21)	//check for the type of 'addExpr' node is correct.
	{
		printf("\n(constant_folding_mul) Correct. numChildren: %d\n", nodeTerm->numChildren);
		
		int sum = 1;
		int sign = 0;
		int i = 0;
		for (i = 0; i < nodeTerm->numChildren; i++)
		{
			if (nodeTerm->children[i]->nodeKind == 23)	//check all term nodes
			{
				if (nodeTerm->children[i]->children[0]->nodeKind == 258)  //INTCONST
				{
					printf("Timing leaf node with value %d.\n", nodeTerm->children[i]->children[0]->val);
					if (sign == 0 || sign == 1)
					{
						sum *= nodeTerm->children[i]->children[0]->val;
					}
					else if (sign == - 1)
					{
						if (nodeTerm->children[i]->children[0]->val == 0)
						{
							printf("\n\nERROR. Divide by 0. \n\n");
							ErrorFlag = 1;
							return 0;
						}
						
						sum /= nodeTerm->children[i]->children[0]->val;
					}
				}
				else
				{
					printf("(constant_folding_mul) At least one leaf node isn't INTCONST. i = %d\n\n", i);
					return 0;
				}
			}
			else if (nodeTerm->children[i]->nodeKind == 24) //mulop
			{
				if (nodeTerm->children[i]->children[0]->nodeKind == 271) //OPER_MUL
				{
					printf("mul sign\n");
					sign = 1;
				}
				else
				{
					printf("div sign\n");
					sign = -1;
				}	
			}
			else if (nodeTerm->children[i]->children[0]->nodeKind == 4) //var
			{
				printf("var involved.\n\n\n");
			}
			else
			{
				printf("????\n\n\n");
			}
		}
		printf("(constant_folding_mul) final result: %d\n" , sum);
		return sum;
	}
	else
	{
		printf("????\n\n\n");
		return 0;
	}
}




//check if an ID is/isn't an array, and check its boundary.
int check_array(char* IDarray, tree* nodeAddExpr )
{
	printf("(check_array) Checking array boundary\n");
	/* not an array. the second argument is 0. */
	if (nodeAddExpr == 0)
	{
		struct tableNode* nodeID = ST_lookup(IDarray, 1);
		if (nodeID == 0)
		{
			nodeID = ST_lookup(IDarray, 11);
		}
		if (nodeID == 0)
		{
			nodeID = ST_lookup(IDarray, 0);
		}
		if (nodeID->sizeArray != 0)
		{
			return 0;
		}
	}
	else /* ID is an array. the second argument is not 0.*/
	{
		if (nodeAddExpr->nodeKind == 19)	//check for the type of 'addExpr' node is correct.
		{
			struct tableNode* nodeID = ST_lookup(IDarray, 1);
			if (nodeID == 0)
			{
				nodeID = ST_lookup(IDarray, 11);
			}
			if (nodeID == 0)
			{
				nodeID = ST_lookup(IDarray, 0);
			}
			if (nodeID->sizeArray == 0) //ID was not an array type.
			{
				return 0;
			}
			
			printf("sizearray = %d\n", nodeID->sizeArray);
			printf("int = %d\n", nodeAddExpr->children[0]->children[0]->children[0]->nodeKind);
			if (nodeID->sizeArray < 0)  //argument. size = -1. index doesn't matter
			{
				return 1;
			}
			else if (nodeID->sizeArray > 0)
			{
				//Here we meet two condition. One is pure int result in [ ]. In this case, we compare it with array size.
				//The other one is int + variable in [ ]. Since we don't know the result, we don't give error message.
				if (nodeAddExpr->children[0]->children[0]->children[0]->nodeKind == 258)
				{
					printf("Only int index.\n");
					if (nodeAddExpr->children[0]->children[0]->children[0]->val <= nodeID->sizeArray)
					{
						return 1;
					}
					else
					{
						return 0;
					}
				}
			}
			else  //ID was not an array type.
			{
				return 0;
			}
			return 1;
		}
		else
		{
			printf("\n\else from check_array. \n\n");
		}
	}
	return 1;
	
	
}


//INTCONST 258 CHARCONST 259 KWD_INT 264 KWD_CHAR 266 KWD_VOID 268
int check_assign_type(tree* nodeVar, tree* nodeAddExpr)
{
	printf("(check_assign_type) checking compatible type.\n");
	nodeAddExpr = nodeAddExpr->children[0];
	int typeLHS;
	
	struct tableNode* nodeID = ST_lookup(nodeVar->children[0]->valStr, 1);
	if (nodeID == 0)
	{
		nodeID = ST_lookup(nodeVar->children[0]->valStr, 11);
	}
	if (nodeID == 0)
	{
		nodeID = ST_lookup(nodeVar->children[0]->valStr, 0);
	}
	
	printf("The type of LHS is %d", nodeID->type);
	typeLHS = nodeID->type;
	if (typeLHS == 264){}
	
	
	if (nodeAddExpr->nodeKind == 19)	//check for the type of 'addExpr' node is correct.
	{
		printf("(check_assign_type) Correct. numChildren: %d\n", nodeAddExpr->numChildren);
		int i = 0;
		for (i = 0; i < nodeAddExpr->numChildren; i++)
		{
			if (nodeAddExpr->children[i]->nodeKind == 21)	//check all term nodes
			{
				if (typeLHS == 264 && nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 258 ||
				typeLHS == 264 && nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 264 )
				{
					printf("One leaf node is compatible.\n");
				}
				else if (typeLHS == 266 && nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 259 ||
				typeLHS == 266 && nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 266 )
				{
					printf("One leaf node is compatible.\n");
				}
				else if (nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 4 ||
				nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 25) // var or funcCallExpr
				{
					struct tableNode* nodeID = ST_lookup(nodeAddExpr->children[i]->children[0]->children[0]->children[0]->valStr, 1);
					if (nodeID == 0)
					{
						nodeID = ST_lookup(nodeAddExpr->children[i]->children[0]->children[0]->children[0]->valStr, 11);
					}
					if (nodeID == 0)
					{
						nodeID = ST_lookup(nodeAddExpr->children[i]->children[0]->children[0]->children[0]->valStr, 0);
					}
					if (nodeID == 0)
					{
						printf("ERROOOOOOOOR\n\n");
						return 0;
					}
					
					printf("leaf node type is %d.\n", nodeID->type);
					
					if (typeLHS == 264 && nodeID->type == 264)
					{
						printf("One leaf node is ID with compatible return type.\n");
					}
					else if (typeLHS == 266 && nodeID->type == 266)
					{
						printf("One leaf node is ID with compatible return type.\n");
					}
					else if (typeLHS == 268 && nodeID->type == 268)
					{
						printf("One leaf node is ID with compatible return type.\n");
					}
					else
					{
						printf("At least one leaf node isn't compatible. i = %d\n\n", i);
						return 0;
					}
				}
				else
				{
					printf("At least one leaf node isn't compatible. i = %d\n\n", i);
					return 0;
				}
			}
		}
		
		
		//mul checking
		for (i = 0; i < nodeAddExpr->numChildren; i++)
		{
			if (nodeAddExpr->children[0]->children[i]->nodeKind == 23)	//check all factor nodes
			{
				if (typeLHS == 264 && nodeAddExpr->children[0]->children[i]->children[0]->nodeKind == 258 ||
				typeLHS == 264 && nodeAddExpr->children[0]->children[i]->children[0]->nodeKind == 264 )
				{
					printf("One leaf node is compatible.\n");
				}
				else if (typeLHS == 266 && nodeAddExpr->children[0]->children[i]->children[0]->nodeKind == 259 ||
				typeLHS == 266 && nodeAddExpr->children[0]->children[i]->children[0]->nodeKind == 266 )
				{
					printf("One leaf node is compatible.\n");
				}
				else if (nodeAddExpr->children[0]->children[i]->children[0]->nodeKind == 4 ||
				nodeAddExpr->children[0]->children[i]->children[0]->nodeKind == 25) // var or funcCallExpr
				{
					struct tableNode* nodeID = ST_lookup(nodeAddExpr->children[0]->children[i]->children[0]->children[0]->valStr, 1);
					if (nodeID == 0)
					{
						nodeID = ST_lookup(nodeAddExpr->children[0]->children[i]->children[0]->children[0]->valStr, 11);
					}
					if (nodeID == 0)
					{
						nodeID = ST_lookup(nodeAddExpr->children[0]->children[i]->children[0]->children[0]->valStr, 0);
					}
					if (nodeID == 0)
					{
						printf("ERROOOOOOOOR\n\n");
						return 0;
					}
					
					printf("leaf node type is %d.\n", nodeID->type);
					
					if (typeLHS == 264 && nodeID->type == 264)
					{
						printf("One leaf node is ID with compatible return type.\n");
					}
					else if (typeLHS == 266 && nodeID->type == 266)
					{
						printf("One leaf node is ID with compatible return type.\n");
					}
					else if (typeLHS == 268 && nodeID->type == 268)
					{
						printf("One leaf node is ID with compatible return type.\n");
					}
					else
					{
						printf("At least one leaf node isn't compatible. i = %d\n\n", i);
						return 0;
					}
				}
				else
				{
					printf("At least one leaf node isn't compatible. i = %d\n\n", i);
					return 0;
				}
			}
		}
		
		
		
		//printf("\n\n");
		return 1;
	}
	else
	{
		printf("(check_assign_type) Incorrect. The nodeKind is %d\n" , nodeAddExpr->nodeKind);
	}
	
	return 0;
}



//go through the subtree of an 'addExpr' node and check it's final return type.
//if the result from this 'addExpr' expression is INTCONST, return 1.
//addExpr 19 term 21 factor 23
int type_addExpr(tree* nodeAddExpr)
{
	if (nodeAddExpr->nodeKind == 19)	//check for the type of 'addExpr' node is correct.
	{
		printf("(type_addExpr) Correct. numChildren: %d\n", nodeAddExpr->numChildren);
		int i = 0;
		for (i = 0; i < nodeAddExpr->numChildren; i++)
		{
			if (nodeAddExpr->children[i]->nodeKind == 21)	//check all term nodes
			{
				if (nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 258)
				{
					printf("One leaf node is INTCONST.\n");
				}
				else if (nodeAddExpr->children[i]->children[0]->children[0]->nodeKind == 4) // var
				{
					struct tableNode* nodeID = ST_lookup(nodeAddExpr->children[i]->children[0]->children[0]->children[0]->valStr, 1);
					if (nodeID == 0)
					{
						nodeID = ST_lookup(nodeAddExpr->children[i]->children[0]->children[0]->children[0]->valStr, 11);
					}
					if (nodeID == 0)
					{
						nodeID = ST_lookup(nodeAddExpr->children[i]->children[0]->children[0]->children[0]->valStr, 0);
					}
					if (nodeID == 0)
					{
						printf("ERROOOOOOOOR\n\n");
						return 0;
					}
					
					printf("leaf node type is %d.\n", nodeID->type);
					
					if (nodeID->type == 264)
					{
						printf("One leaf node is ID with return type INT.\n");
					}
					else
					{
						printf("At least one leaf node isn't INTCONST. i = %d\n\n", i);
						return 0;
					}
					
				}
				else
				{
					printf("At least one leaf node isn't INTCONST. i = %d\n\n", i);
					return 0;
				}
			}
		}
		//printf("\n\n");
		return 1;
	}
	printf("(type_addExpr) Incorrect. The nodeKind is %d\n" , nodeAddExpr->nodeKind);
	return 0;
}

//argList 26 expression 18 addExpr 19 term 21 factor 23 
//var 4 INTCONST 258 CHARCONST 259 KWD_INT 264 KWD_CHAR 266 KWD_VOID 268 KWD_VOID 268
int check_argList(char* nameID, tree* nodeArgList)
{
	if (nodeArgList->nodeKind == 26)
	{
		printf("(check_argList) Checking argument numbers and types. numChildren: %d\n", nodeArgList->numChildren);
		
		struct tableNode* nodeID = ST_lookup(nameID, 0);	//finding function ID in the table (should be global)
		display_argumentInfo(nodeID);
		int countArg = 0;
		
		int i = 0;
		for (i = 0; i < nodeArgList->numChildren; i++)
		{
			if (nodeArgList->children[i]->nodeKind == 18)	//check all expression nodes
			{
				
				if (countArg > nodeID->numArgument)
				{
					printf("\nERROR. The arguments numbers are wrong for function \'%s\'.\n\n", nameID);
					ErrorFlag = 1;
					return 0;
				}
				if (nodeArgList->children[i]->children[0]->children[0]->children[0]->nodeKind == 23) /* factor */
				{
					printf("i = %d, countArg = %d\n", i, countArg);
					if (nodeArgList->children[i]->children[0]->children[0]->children[0]->children[0]->nodeKind == 4) /* var */
					{
						char* nameID2 = nodeArgList->children[i]->children[0]->children[0]->children[0]->children[0]->children[0]->valStr;
						struct tableNode* nodeID2 = ST_lookup(nameID2, 0);
						if (nodeID2 != 0)
						{
							printf("Variable \'%s\' return type: %d, compare with %d  \n", nameID2, nodeID2->type, nodeID->typeArgument[countArg]);
							if (nodeID2->type == nodeID->typeArgument[countArg])
							{
								printf("pass...\n");
							}
							else
							{
								printf("\nERROR. Argument types don't match for function \'%s\'.\n\n", nameID);
								ErrorFlag = 1;
							}
						}
						else
						{
							printf("\nERROR. ID name \'%s\' is undefined.\n\n", nameID2);
							ErrorFlag = 1;
						}
					}
					else if (nodeArgList->children[i]->children[0]->children[0]->children[0]->children[0]->nodeKind == 258) //INTCONST
					{
						printf("INTCONST 258, compare with %d  \n", nodeID->typeArgument[countArg]);
						if (nodeID->typeArgument[countArg] == 264)
						{
							printf("pass...\n");
						}
						else
						{
							printf("\nERROR. Argument types don't match for function \'%s\'.\n\n", nameID);
							ErrorFlag = 1;
						}
					}
					else if (nodeArgList->children[i]->children[0]->children[0]->children[0]->children[0]->nodeKind == 259) //CHARCONST
					{
						printf("CHARCONST 259, compare with %d  \n", nodeID->typeArgument[countArg]);
						if (nodeID->typeArgument[countArg] == 266)
						{
							printf("pass...\n");
						}
						else
						{
							printf("\nERROR. Argument types don't match for function \'%s\'.\n\n", nameID);
							ErrorFlag = 1;
						}
					}
					else
					{
						printf("else from check_argList\n\n");
					}
					
					/* need to handle local = 12 */
					//printf("leaf node is %d type.\n", nodeFormalDeclList->children[i]->children[0]->children[0]->nodeKind);
					//nodeID->typeArgument[nodeID->numArgument] = nodeFormalDeclList->children[i]->children[0]->children[0]->nodeKind;
					//nodeID->numArgument++;
				}
				else
				{
					printf("\nWhat's this? i = %d\n\n", i);
				}
				countArg++;
			}
		}
	}
	else if (nodeArgList->nodeKind == 284)
	{
		struct tableNode* nodeID = ST_lookup(nameID, 0);	//finding function ID in the table (should be global)
		if (nodeID->numArgument != 0)
		{
			printf("\nERROR. Argument numbers don't match for function \'%s\'.\n\n", nameID);
			ErrorFlag = 1;
		}
		
	}
	else
	{
		printf("\nWhat's this?  from check_argList    nodeKind = %d\n\n", nodeArgList->nodeKind);
	}
	
	
	printf("\n");
	return 1;
}




//formalDeclList 9 formalDecl 8 typeSpecifier 2 KWD_INT 34 KWD_CHAR 36 KWD_VOID 38
void record_argument(char* nameID, tree* nodeFormalDeclList)
{
	if (nodeFormalDeclList->nodeKind == 9)
	{
		printf("(record_argument) Recording argument types. numChildren: %d\n", nodeFormalDeclList->numChildren);
		struct tableNode* nodeID = ST_lookup(nameID, 0);	//finding function ID in the table (should be global)
		int i = 0;
		for (i = 0; i < nodeFormalDeclList->numChildren; i++)
		{
			if (nodeFormalDeclList->children[i]->nodeKind == 8)	//check all formalDecl nodes
			{
				if (nodeFormalDeclList->children[i]->children[0]->nodeKind == 2) /*useless cond?*/
				{
					/* need to handle local = 12 */
					printf("leaf node is %d type.\n", nodeFormalDeclList->children[i]->children[0]->children[0]->nodeKind);
					nodeID->typeArgument[nodeID->numArgument] = nodeFormalDeclList->children[i]->children[0]->children[0]->nodeKind;
					nodeID->numArgument++;
				}
				else
				{
					printf("What's this? i = %d\n\n", i);
				}
			}
		}
		display_argumentInfo(nodeID);
		
	}
	
	
	printf("\n");
	return;
	
}


void display_argumentInfo(struct tableNode* nodeID)
{
	int i;
	printf("Printing argument info for function: %s\n %d arguments: ", nodeID->name, nodeID->numArgument);
	for (i = 0; i < nodeID->numArgument; i++)
	{
		printf("%d  ", nodeID->typeArgument[i]);
	}
	printf("\n");
	
}


////////////////////////////////////////////////


//20 variables with 30 length for their names
#define MAXVAR 20
#define MAXVARLENGTH 30
#define MAXLAYER 5

char listVar[MAXLAYER][MAXVAR][MAXVARLENGTH];
char listLabelFun[MAXVAR][MAXVARLENGTH];
int layerCurrent = 0;
int numLabel = 0;

FILE * fileMips;




int codeGenStart()
{
    fileMips = fopen ("myfile.mips","w");
    if (fileMips!=NULL)
    {
        fprintf(fileMips, ".text\n.globl main\n\nj main\n");
		
		fprintf(fileMips, "output:\nli  $v0, 1\nsyscall\njr $ra\n");
    }
    else
    {
        printf("\nERROR. File failed to open.\n\n");
    }

    
}




int getSP(char* str) //return the offset for a specific ID
{
	int i;
	for (i = 0; i < MAXVAR; i++)
	{
		if (strcmp( listVar[layerCurrent][i], str ) == 0)
		{
			return i * 4;
		}
	}
	printf("Variable name %s not found.", str);
	return -1;
}



//display ListVar
void displayListVar()
{
	int i, j;
	for (i = 0; i < MAXLAYER; i++)
	{
		printf("Layer%d:\n", i);
		for (j = 0; j < MAXVAR; j++)
		{
			printf("%d  %s  ", j, listVar[i][j]);
		}
		printf("\n");
	}
}



int codeGen(tree* node, int layer)
{
	//printf("(codeGen)  start layer = %d\n", layer);
	
	if (1!=1)
	{

	}
	else if (node->nodeKind == 1) //var Declare (varDecl 1)
	{
		//printf("(codeGen)  var decl\n");
		
		int i;
		for (i = 0; i < MAXVARLENGTH; i++) //put the ID into listVar
		{
			if (strcmp( listVar[layer][i], "" ) == 0)
			{
				//listVar[layer][i] = node->children[1]->valStr;
				strcpy(listVar[layer][i], node->children[1]->valStr);

				//output mips
				//fprintf(fileMips, "# variable %s is in stack  %d now.\n", listVar[layer][i], getSP(listVar[layer][i]));
				break;
			}
			else if (i == MAXVARLENGTH - 1)
			{
				printf("\nERROR. Too much variables.\n\n");
			}
		}
	}
	else if (node->nodeKind == 3 && (node->children[0]->nodeKind == 4||node->children[0]->nodeKind == 234)) //assign Statement (assignStmt 3)
	{
		printf("(codeGen)  assgn state\n");
		
		char* nodeID = node->children[0]->children[0]->valStr;
		int valueAssign = node->children[2]->children[0]->children[0]->children[0]->children[0]->val;

		fprintf(fileMips, "li $t0, %d\nsw $t0, %d($sp)\n", valueAssign, getSP(nodeID) );
	}
	else if (node->nodeKind == 15) //condition Statement (condStmt 15)
	{
		//printf("(codeGen)  condi state\n");
		
		
		char* nodeID1 = node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->children[0]->valStr; //first ID
		char* nodeID2; //second ID
		int valueCompare;
		int operation = node->children[2]->children[1]->children[0]->nodeKind; //
		int numLableHere = numLabel;

		fprintf(fileMips, "lw $t0, %d($sp)\n", getSP(nodeID1) );

		if (node->children[2]->children[2]->children[0]->children[0]->children[0]->nodeKind == 258) //INTCONST
		{
			valueCompare = node->children[2]->children[2]->children[0]->children[0]->children[0]->val;
			fprintf(fileMips, "li $t1, %d\n", valueCompare);
		}
		else if (node->children[2]->children[2]->children[0]->children[0]->children[0]->nodeKind == 4) //var
		{
			nodeID2 = node->children[2]->children[2]->children[0]->children[0]->children[0]->children[0]->valStr; //second ID
			fprintf(fileMips, "lw $t1, %d($sp)\n", getSP(nodeID2) );
		}
		else
		{
			printf("\nERROR. from condition statement. %d\n\n", node->children[2]->children[2]->children[0]->children[0]->children[0]->nodeKind);
		}

		if (operation == 274) // >
		{
			fprintf(fileMips, "ble ");
		}
		else if (operation == 273) // <
		{
			fprintf(fileMips, "bge ");
		}
		else if (operation == 277) // ==
		{
			fprintf(fileMips, "bne ");
		}
		else
		{
			printf("\nERRORRR? %d\n\n", operation);
		}

		numLabel+= 2;

		fprintf(fileMips, " $t0, $t1, LabelElse%d\n", numLableHere);
		//something 1

			codeGen(node->children[4], layerCurrent);

		
		fprintf(fileMips, "j LabelIfEnd%d\n", numLableHere + 1);
		
		fprintf(fileMips, "\nLabelElse%d:\n", numLableHere);
		//something 2

			codeGen(node->children[6], layerCurrent);

		
		fprintf(fileMips, "\nLabelIfEnd%d:\n", numLableHere + 1);


	}
	else if (node->nodeKind == 16) //loop Statement (loopStmt 16)
	{
		//printf("(codeGen)  loop state\n");
		
		
		char* nodeID1 = node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->children[0]->valStr; //first ID
		char* nodeID2; //second ID
		int valueCompare;
		int operation = node->children[2]->children[1]->children[0]->nodeKind; //
		int numLableHere = numLabel;
		numLabel+= 2;

		fprintf(fileMips, "lw $t0, %d($sp)\n", getSP(nodeID1) );

		if (node->children[2]->children[2]->children[0]->children[0]->children[0]->nodeKind == 258) //INTCONST
		{
			valueCompare = node->children[2]->children[2]->children[0]->children[0]->children[0]->val;
			fprintf(fileMips, "li $t1, %d\n", valueCompare);
		}
		else if (node->children[2]->children[2]->children[0]->children[0]->children[0]->nodeKind == 4) //var
		{
			nodeID2 = node->children[2]->children[2]->children[0]->children[0]->children[0]->children[0]->valStr; //second ID
			fprintf(fileMips, "lw $t1, %d($sp)\n", getSP(nodeID2) );
		}
		else
		{
			printf("\nERROR. from condition statement. %d\n\n", node->children[2]->children[2]->children[0]->children[0]->children[0]->nodeKind);
		}

		
		fprintf(fileMips, "\nLabelWhile%d:\n", numLableHere);
		
		if (operation == 274) // >
		{
			fprintf(fileMips, "ble ");
		}
		else if (operation == 273) // <
		{
			fprintf(fileMips, "bge ");
		}
		else if (operation == 277) // ==
		{
			fprintf(fileMips, "bne ");
		}
		else
		{
			printf("\nERRORRR? %d\n\n", operation);
		}

		

		
		
		fprintf(fileMips, " $t0, $t1, LabelWhileEnd%d\n", numLableHere + 1);

		//something
		int i;
		for (i = 0; i < node->numChildren; i++)
		{
			codeGen(node->children[i], layerCurrent);
		}
		
		fprintf(fileMips, "j LabelWhile%d\n", numLableHere);
		fprintf(fileMips, "\nLabelWhileEnd%d:\n", numLableHere + 1);


	}
	else if (node->nodeKind == 7) //function Declare (funDecl 7)
	{
        char* funID = node->children[1]->valStr;
		
		//printf("(codeGen)  fun decl\n");
		if (strcmp(funID, "main") == 0)
		{
			fprintf(fileMips, "\nmain:");
		}
		
		
		//record the label info for this function
		strcpy(listLabelFun[numLabel], funID);
		
		
		fprintf(fileMips, "\nLabel%d:\n", numLabel);
		numLabel++;

		fprintf(fileMips, "addiu $sp, $sp, -104\n");
		fprintf(fileMips, "sw $ra, 100($sp)\n");
		fprintf(fileMips, "sw $fp, 96($sp)\n");
		fprintf(fileMips, "addiu $fp, $sp, 104\n");

        layerCurrent++;
		
		//store augment
		if (node->children[3]->nodeKind == 9) //(formalDeclList 8)
		{
			//printf("\nHERRRRRRRRRRRRRRRR %s\n\n", node->children[3]->children[0]->children[1]->valStr);
			strcpy(listVar[layerCurrent][0], node->children[3]->children[0]->children[1]->valStr);
		}
		
		
		//something
		int i;
		for (i = 0; i < node->numChildren; i++)
		{
			codeGen(node->children[i], layerCurrent);
		}

		layerCurrent--;
		fprintf(fileMips, "lw $fp, 96($sp)\n");
		fprintf(fileMips, "lw $ra, 100($sp)\n");
		fprintf(fileMips, "addiu $sp, $sp, 104\n");
		if (strcmp(funID, "main") != 0)
		{
			fprintf(fileMips, "jr $ra\n");
		}
	}
	else if (node->nodeKind == 25) // function call (funcCallExpr 25)
	{
		//printf("(codeGen)  funCall\n");
		
		char* funID = node->children[0]->valStr;
		char* augID;
		int augValue;

		
		if (node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->nodeKind == 258) //INTCONST
		{
			augValue = node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->val;
			fprintf(fileMips, "li $a0, %d\n", augValue);
		}
		else if (node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->nodeKind == 4) //var
		{
			augID = node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->children[0]->valStr; //ID
			fprintf(fileMips, "lw $a0, %d($sp)\n", getSP(augID) );
		}
		else
		{
			printf("\nERROR. from function call. %d\n\n", node->children[2]->children[0]->children[0]->children[0]->children[0]->children[0]->nodeKind);
		}
		
		if (strcmp(funID, "output") == 0)
		{
			fprintf(fileMips, "jal output\n");
			
		}
		else
		{
			//get label name for this function
			int i;
			for (i = 0; i < MAXVAR; i++)
			{
				if (strcmp(listLabelFun[i], funID) == 0)
				{
					break;
				}
			}

			fprintf(fileMips, "jal Label%d\n", i);
		}
	}
	else if (node->numChildren > 0) //with no key node and no leaf node, go deeper
	{
		//printf("(codeGen)  going deep\n");
		
		int i;
		for (i = 0; i < node->numChildren; i++)
		{
			codeGen(node->children[i], layerCurrent);
		}
	}
	else
	{
		//printf("(codeGen)  leaf\n");
		//printf("Reached leave: nodeKind = %d\n", node->nodeKind);
		return node->nodeKind;
	}
	return 0;
}












//////////////////////////////////////////////////



int yyerror(char * msg) {
  printf("error: in line %d type: %s\n", yylineno, msg);
  return 0;
}

	 
int main() {

  printf("Start.\n\n");
  if (!yyparse() && ErrorFlag == 0)
  {
	printf("Accept.\n\n");
	printAst(ast, 1);
	printf("Tree shown above.\n\n");
	
	display_table();
	
	printf("\nStart to print out. \n\n");
	codeGenStart();
	
	codeGen(ast, 0);
	displayListVar();
	fclose (fileMips);
	
	
	
  }
  else
  {
	printf("Doesn't accept.\n\n");
	printAst(ast, 1);
  }
	
  return 0;
}


