%{
#include <stdio.h>
#include <stdbool.h>
#include <stdarg.h> 
#include "node.type.h"
#include "hashing.c"

#define SYMTABSIZE	997
#define IDLENGTH	15

enum PARSE_TREE_NODE_TYPE {DECLARATION,TYPE_SPECIFIER, DECLARATION_BLOCK, DECLARATION_LIST, ID};
const char* labels[] = {"DECLARATION","TYPE_SPECIFIER", "DECLARATION_BLOCK", "DECLARATION_LIST", "ID"};

nodeType *opr(int oper, int nops, ...);
nodeType *get_id(int i);
nodeType *constant(int value);

char *id[100];
char *type[100];

int yylex();
int yyerror(char *s);

/* parse tree */
struct treeNode {
	struct value{
		union {
			int i;
			long double f;
			char *s;
		} value;
		char *use;
	} val;
	int nodeIdentifier;
	struct treeNode *first;
	struct treeNode *second;
	struct treeNode *third;
	struct treeNode *fourth;
};
typedef struct treeNode TREE_NODE;
typedef TREE_NODE *B_TREE;
B_TREE create_node(struct value, int, B_TREE, B_TREE, B_TREE, B_TREE);
int find_usage(B_TREE, char *type[100], int, char *u);
B_TREE tree_to_print;

/* symbol table */
struct symTabNode {
	char identifier[IDLENGTH];
	char type[100];
};
typedef struct symTabNode SYMTABNODE;
typedef SYMTABNODE *SYMTABNODEPTR;
SYMTABNODEPTR symTab[SYMTABSIZE];
int currentSymTabSize=0;

void PrintTree(B_TREE);
%}

/* Basic data types */
%union {
  int intValue; /* integer value */
  char charValue; /* char value */
  char *strValue; /* string value */
  bool boolValue; /* boolean value */
  long double realValue; /* real value */
  B_TREE treeVal; /* node pointer */
};

%token <intValue> INT
%token <charValue> CHAR
%token <strValue> IDENTIFIER STRING
%token <boolValue> BOOLEAN
%token <realValue> REAL

%token VAR DIV MOD AND OR NOT ABS LOG EXP BEG END TRUE FALSE IF THEN ELSE WHILE DO FOR TO READ WRITE FUNCTION RETURN NULL_VALUE EQ INF INFEQ SUP SUPEQ NOTEQ COMMA TAB COM_BEG COM_END NEWLINE DECLARATOR ASSIGNATOR

/* The last definition listed has the highest precedence. Consequently multiplication and division have higher
precedence than addition and subtraction. All four operators are left-associative. */
%right ASSIGNATOR DECLARATOR
%left AND OR NOT NOTEQ SUP SUPEQ INF INFEQ EQ
%left '+' '-'
%left '*' '/' DIV MOD 
%nonassoc UMINUS  /*supplies precedence for unary minus */

%type <treeVal> declaration_block declaration expr type_specifier declaration_list id_declaration

/* beginning of rules section */
%%  
declaration_block:
  VAR NEWLINE declaration { 
      struct value empty_node; empty_node.use="none";
      $$ = create_node(empty_node,DECLARATION_BLOCK,$3,NULL,NULL,NULL); 
  }
  |
  declaration_block NEWLINE declaration { 
      struct value empty_node; empty_node.use="none";
      tree_to_print = create_node(empty_node,DECLARATION_BLOCK,$1,$3,NULL,NULL); 
      PrintTree(tree_to_print);
      $$ = tree_to_print;
  }
  ;

declaration:
  declaration_list DECLARATOR type_specifier {
    struct value empty_node; empty_node.use="none";
    $$ = create_node(empty_node,DECLARATION,$1,$3,NULL,NULL);
		int i, j, type_index = 0, id_index = 0;
		for(i = 0; i < 100; i++) {
			id[i] = (char *)malloc(IDLENGTH*sizeof(char));
			strcpy(id[i],"NULL");
			type[i] = (char *)malloc(10*sizeof(char));
			strcpy(type[i],"NULL");
		}
    
		id_index = find_usage($1,id,id_index,"identifier");
    type_index = find_usage($3,type,type_index,"string");
		for(i=0;i<id_index;i++) {
			for(j=1;j<type_index;j++) {
				if(strcmp(type[j],"NULL")!=0) {
					strcat(type[0]," ");
					strcat(type[0],type[j]);
				}
			}
			hash_insert(id[i],type[0]);
		}
	}
  ;

declaration_list: 
  id_declaration { 
    struct value empty_node; empty_node.use="none";
		$$ = create_node(empty_node,DECLARATION_LIST,$1,NULL,NULL,NULL);
  }
  | declaration_list COMMA id_declaration { 
      struct value empty_node; empty_node.use="none";
      $$ = create_node(empty_node,DECLARATION_LIST,$1,$3,NULL,NULL); 
    }
  ;

id_declaration:
  IDENTIFIER { 
    struct value new_node;
		new_node.value.s = yylval.strValue;
		new_node.use = "identifier";
		$$ = create_node(new_node,ID,NULL,NULL,NULL,NULL);
  }
  ;

type_specifier:
  INT { 
    struct value new_node;
		new_node.value.s = "int";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | CHAR {
    struct value new_node;
		new_node.value.s = "char";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | STRING {
    struct value new_node;
		new_node.value.s = "string";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | BOOLEAN {
    struct value new_node;
		new_node.value.s = "bool";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | REAL {
    struct value new_node;
		new_node.value.s = "real";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  ;

expr: 
  INT { $$ = constant($1); }
  | REAL { $$ = constant($1); }
  | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
  | expr '+' expr  { $$ = opr('+', 2, $1, $3); }
  | expr '-' expr  { $$ = opr('-', 2, $1, $3); }
  | expr '*' expr  { $$ = opr('*', 2, $1, $3); }
  | expr '/' expr  { $$ = opr('/', 2, $1, $3); }
  | expr INF expr  { $$ = opr(INF, 2, $1, $3); }
  | expr AND expr  { $$ = opr(AND, 2, $1, $3); }
  | expr OR expr  { $$ = opr(OR, 2, $1, $3); }
  | expr NOT expr  { $$ = opr(NOT, 2, $1, $3); }
  | expr SUP expr  { $$ = opr(SUP, 2, $1, $3); }
  | expr SUPEQ expr  { $$ = opr(GE, 2, $1, $3); }
  | expr INFEQ expr  { $$ = opr(LE, 2, $1, $3); }
  | expr NOTEQ expr  { $$ = opr(NE, 2, $1, $3); }
  | expr EQ expr  { $$ = opr(EQ, 2, $1, $3); }
  | expr DIV expr  { $$ = opr(DIV, 2, $1, $3); }
  | expr MOD expr { $$ = opr(MOD, 2, $1, $3); }
  | '(' expr ')'  { $$ = $2; }
  ;
%%

#define SIZEOF_NODETYPE ((char *)&p->constant - (char *)p)

nodeType *constant(int value) {
  nodeType *p;
  /* allocate node */
  if ((p = malloc(sizeof(nodeType))) == NULL)
  yyerror("out of memory");
  /* copy information */
  p->type = typeConstant;
  p->constant.value = value;
  return p;
}

nodeType *get_id(int i) {
  nodeType *p;
  /* allocate node */
  if ((p = malloc(sizeof(nodeType))) == NULL)
  yyerror("out of memory");
  /* copy information */
  p->type = typeId;
  p->id.i = i;
  return p;
}

nodeType *opr(int oper, int nops, ...) {
  va_list ap;
  nodeType *p;
  int i;
  /* allocate node, extending op array */
  if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
  yyerror("out of memory");
  /* copy information */
  p->type = typeOpr;
  p->opr.oper = oper;
  p->opr.nops = nops;
  va_start(ap, nops);
  for (i = 0; i < nops; i++)
  p->opr.op[i] = va_arg(ap, nodeType*);
  va_end(ap);
  return p;
}

B_TREE create_node(struct value val,int case_identifier,B_TREE p1,B_TREE p2,B_TREE p3,B_TREE p4) {
	B_TREE t;
	t = (B_TREE)malloc(sizeof(TREE_NODE));
  if (strcmp(val.use,"identifier")) printf("node created value:%s\n", val.value.s);
	t->val = val;
	t->nodeIdentifier = case_identifier;
	t->first = p1;
	t->second = p2;
	t->third = p3;
	t->fourth = p4;
	return (t);
}

int find_usage(B_TREE p,char *type[100],int i,char *u) {
  if(p == NULL)
    return i;
  if(strcmp(p->val.use,u) == 0) {
    strcpy(type[i],p->val.value.s);
    i++;
  }
  i=find_usage(p->first,type,i,u);
  i=find_usage(p->second,type,i,u);
  i=find_usage(p->third,type,i,u);
  i=find_usage(p->fourth,type,i,u);
  return i;
}

void PrintTree(B_TREE t) {
	if(t==NULL)
		return; 
	if(strcmp(t->val.use,"string")==0)
		printf("Value: %s ",t->val.value.s);
	if(strcmp(t->val.use,"identifier")==0)
		printf("Value: %s ",t->val.value.s);
	else if(strcmp(t->val.use,"float")==0)
		printf("Value: %Lf ",t->val.value.f);
	else if(strcmp(t->val.use,"integer")==0)
		printf("Value: %d ",t->val.value.i);
	else 
		printf("Value: ");

	printf("Label: %s\n",labels[(t->nodeIdentifier)]);
	//if(t->first!=NULL) printf("Going from %s to %s\n",labels[t->nodeIdentifier],labels[t->first->nodeIdentifier]);
	PrintTree(t->first);
	//if(t->second!=NULL) printf("Going from %s to %s\n",labels[t->nodeIdentifier],labels[t->second->nodeIdentifier]);
	PrintTree(t->second);
	//if(t->third!=NULL) printf("Going from %s to %s\n",labels[t->nodeIdentifier],labels[t->third->nodeIdentifier]);
	PrintTree(t->third);
	//if(t->fourth!=NULL) printf("Going from %s to %s\n",labels[t->nodeIdentifier],labels[t->fourth->nodeIdentifier]);
	PrintTree(t->fourth);
}

int yyerror(char *s) {
  fprintf(stderr, "%s\n", s);
  return 0;
}