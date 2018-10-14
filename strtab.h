#define MAXIDS 1000
#define LENGTH 100
#define MAXLOCAL 20
#define MAXHASH 100

enum dataType {INT_TYPE, CHAR_TYPE, VOID_TYPE};

struct tableNode
{
	char* name;
	int scope;	//scope
	int type;
	int sizeArray;
	int numArgument;
	int typeArgument[MAXARGUMENT];
	struct tableNode* ptrNext;
};

struct tableNode symbolTable[MAXHASH];