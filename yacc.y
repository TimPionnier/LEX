%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h> 
#include "types.h"
#include "hashing.c"
#include "parseTreeToPython.c"

#define SYMTABSIZE	997
#define IDLENGTH	15

char *id[100];
char *type[100];

int yylex();
int yyerror(char *s);


B_TREE create_node(struct TreeValue, int, B_TREE, B_TREE, B_TREE, B_TREE);
int find_usage(B_TREE, char *type[100], int, char *use);

/* symbol table */
struct symTabNode {
	char identifier[IDLENGTH];
	char type[100];
};
typedef struct symTabNode SYMTABNODE;
typedef SYMTABNODE *SYMTABNODEPTR;
SYMTABNODEPTR symTab[SYMTABSIZE];

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

%token <intValue> INT_VALUE
%token <realValue> REAL_VALUE
%token <charValue> CHAR_VALUE
%token <boolValue> BOOLEAN_VALUE
%token <strValue> IDENTIFIER STRING_VALUE STRING CHAR BOOLEAN COMMENT


%token VAR DIV MOD AND OR NOT ABS LOG EXP BEG END IF THEN ELSE WHILE DO FOR TO READ WRITE FUNCTION RETURN NULL_VALUE EQ INF INFEQ SUP SUPEQ NOTEQ COMMA TAB NEWLINE DECLARATOR ASSIGNATOR INT REAL END_INPUT TERMINATOR VOID

/* The last definition listed has the highest precedence. Consequently multiplication and division have higher
precedence than addition and subtraction. All four operators are left-associative. */
%right ASSIGNATOR DECLARATOR
%left AND OR NOT NOTEQ SUP SUPEQ INF INFEQ EQ
%left '+' '-'
%left '*' '/' DIV MOD 
%nonassoc UMINUS  /*supplies precedence for unary minus */
%nonassoc IFX
%nonassoc ELSE

%type <treeVal> program stmt_block stmt stmt_list declaration_block declaration  declarator_list id_declarator expr type_specifier constant assignation comment_block stmt_block_with_return declaration_list

/* beginning of rules section */
%% 

program:
  stmt_list END_INPUT{
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,PROGRAM,$1,NULL,NULL,NULL); 
    //PrintTree($$);
    define_symtab_scopes($$,"global");
    //check_symtab_scopes();
    print_table();
    //parse_tree_to_python($$,0);
    exit(0);
  }
  ;

stmt_block: 
  BEG NEWLINE stmt_list END stmt_terminator NEWLINE { struct TreeValue empty_node; empty_node.use="none"; $$ = create_node(empty_node,STMT_BLOCK,$3,NULL,NULL,NULL); }

stmt_block_with_return: 
  BEG NEWLINE stmt_list RETURN expr stmt_terminator NEWLINE END stmt_terminator NEWLINE { 
    struct TreeValue empty_node; empty_node.use="none"; 
    $$ = create_node(empty_node,STMT_BLOCK_RETURN,$3,$5,NULL,NULL); 
  }
  | BEG NEWLINE RETURN expr stmt_terminator NEWLINE END stmt_terminator NEWLINE { 
    struct TreeValue empty_node; empty_node.use="none"; 
    $$ = create_node(empty_node,STMT_BLOCK_RETURN,NULL,$4,NULL,NULL); 
  }

stmt_list:
  stmt { struct TreeValue empty_node; empty_node.use="none"; $$ = create_node(empty_node,STMT_LIST,$1,NULL,NULL,NULL); }
  | stmt_list stmt { struct TreeValue empty_node; empty_node.use="none"; $$ = create_node(empty_node,STMT_LIST,$1,$2,NULL,NULL); }
  ;

stmt:
  expr stmt_terminator NEWLINE{
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,STMT,$1,NULL,NULL,NULL); 
  }
  | declaration_block NEWLINE {
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,STMT,$1,NULL,NULL,NULL); 
  }
  | assignation stmt_terminator NEWLINE{
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,STMT,$1,NULL,NULL,NULL); 
  }
  | comment_block {
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,STMT,$1,NULL,NULL,NULL); 
  }
  | IF expr THEN NEWLINE stmt %prec IFX {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,IF_ELSE_STMT,$2,$5,NULL,NULL); 
  }
  | IF expr THEN NEWLINE stmt_block %prec IFX {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,IF_ELSE_STMT,$2,$5,NULL,NULL); 
  }
  | IF expr THEN NEWLINE stmt ELSE NEWLINE stmt {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,IF_ELSE_STMT,$2,$5,$8,NULL); 
  }
  | IF expr THEN NEWLINE stmt_block ELSE NEWLINE stmt_block {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,IF_ELSE_STMT,$2,$5,$8,NULL); 
  }
  | IF expr THEN NEWLINE stmt ELSE NEWLINE stmt_block {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,IF_ELSE_STMT,$2,$5,$8,NULL); 
  }
  | IF expr THEN NEWLINE stmt_block ELSE NEWLINE stmt {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,IF_ELSE_STMT,$2,$5,$8,NULL); 
  }
  | WHILE expr DO NEWLINE stmt {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,WHILE_LOOP,$2,$5,NULL,NULL); 
  }
  | WHILE expr DO NEWLINE stmt_block {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,WHILE_LOOP,$2,$5,NULL,NULL); 
  }
  | FOR assignation TO constant DO NEWLINE stmt {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,FOR_LOOP,$2,$4,$7,NULL); 
  }
  | FOR assignation TO constant DO NEWLINE stmt_block {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,FOR_LOOP,$2,$4,$7,NULL); 
  }
  | READ '(' id_declarator ')' stmt_terminator NEWLINE {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,READ_STMT,$3,NULL,NULL,NULL);
  }
  | WRITE '(' expr ')' stmt_terminator NEWLINE {
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,WRITE_STMT,$3,NULL,NULL,NULL);
  }
  | FUNCTION id_declarator '(' declaration_list ')' DECLARATOR type_specifier NEWLINE stmt_block_with_return {

    int i, j, type_index = 0, id_index = 0, insert_result;

    for(i = 0; i < 100; i++) {
      id[i] = (char *)malloc(IDLENGTH*sizeof(char));
      strcpy(id[i],"NULL");
      type[i] = (char *)malloc(10*sizeof(char));
      strcpy(type[i],"NULL");
    }
    
    //find the number of ids in the current tree
    id_index = find_usage($2,id,id_index,"identifier");
    //find the number of types declaration in the current tree
    type_index = find_usage($7,type,type_index,"string");

    for(i=0;i<id_index;i++) {
      for(j=1;j<type_index;j++) {
        if(strcmp(type[j],"NULL")!=0) {
          strcat(type[0]," ");
          strcat(type[0],type[j]);
        }
      }
      insert_result = hash_insert(id[i],type[0]);
    }

    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,FUNC_STMT,$2,$4,$7,$9);
  }
  | FUNCTION id_declarator '(' declaration_list ')' DECLARATOR type_specifier NEWLINE stmt_block {
    int i, j, type_index = 0, id_index = 0, insert_result;

    for(i = 0; i < 100; i++) {
      id[i] = (char *)malloc(IDLENGTH*sizeof(char));
      strcpy(id[i],"NULL");
      type[i] = (char *)malloc(10*sizeof(char));
      strcpy(type[i],"NULL");
    }
    
    //find the number of ids in the current tree
    id_index = find_usage($2,id,id_index,"identifier");
    //find the number of types declaration in the current tree
    type_index = find_usage($7,type,type_index,"string");

    for(i=0;i<id_index;i++) {
      for(j=1;j<type_index;j++) {
        if(strcmp(type[j],"NULL")!=0) {
          strcat(type[0]," ");
          strcat(type[0],type[j]);
        }
      }
      insert_result = hash_insert(id[i],type[0]);
    }

    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,FUNC_STMT,$2,$4,$7,$9);
  }
  | ignore_newline {}
  ;
  

declaration_block:
  VAR NEWLINE TAB declaration {
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,DECLARATION_BLOCK,$4,NULL,NULL,NULL); 
  } 
  | declaration_block NEWLINE TAB declaration { 
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,DECLARATION_BLOCK,$1,$4,NULL,NULL); 
  }
  ;

declaration_list:
  declaration {struct TreeValue empty_node; empty_node.use="none"; $$ = create_node(empty_node,DECLARATION_LIST,$1,NULL,NULL,NULL); }
  | declaration_list declaration {struct TreeValue empty_node; empty_node.use="none"; $$ = create_node(empty_node,DECLARATION_LIST,$1,$2,NULL,NULL); }

declaration:
  declarator_list DECLARATOR type_specifier stmt_terminator {
    int i, j, type_index = 0, id_index = 0, insert_result;

    for(i = 0; i < 100; i++) {
      id[i] = (char *)malloc(IDLENGTH*sizeof(char));
      strcpy(id[i],"NULL");
      type[i] = (char *)malloc(10*sizeof(char));
      strcpy(type[i],"NULL");
    }
    
    //find the number of ids in the current tree
    id_index = find_usage($1,id,id_index,"identifier");
    //find the number of types declaration in the current tree
    type_index = find_usage($3,type,type_index,"string");

    for(i=0;i<id_index;i++) {
      for(j=1;j<type_index;j++) {
        if(strcmp(type[j],"NULL")!=0) {
          strcat(type[0]," ");
          strcat(type[0],type[j]);
        }
      }
      insert_result = hash_insert(id[i],type[0]);
    }
    struct TreeValue empty_node; empty_node.use="none";
    $$ = create_node(empty_node,DECLARATION,$1,$3,NULL,NULL);
  }
  ;

declarator_list: 
  id_declarator { 
    struct TreeValue empty_node; empty_node.use="none";
		$$ = create_node(empty_node,DECLARATOR_LIST,$1,NULL,NULL,NULL);
  }
  | declarator_list COMMA id_declarator { 
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,DECLARATOR_LIST,$1,$3,NULL,NULL); 
  }
  ;

id_declarator:
  IDENTIFIER { 
    struct TreeValue new_node;
		new_node.v.s = yylval.strValue;
		new_node.use = "identifier";
		$$ = create_node(new_node,ID,NULL,NULL,NULL,NULL);
  }
  ;

type_specifier:
  INT { 
    struct TreeValue new_node;
		new_node.v.s = "int";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | CHAR {
    struct TreeValue new_node;
		new_node.v.s = "char";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | STRING {
    struct TreeValue new_node;
		new_node.v.s = "string";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | BOOLEAN {
    struct TreeValue new_node;
		new_node.v.s = "bool";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | REAL {
    struct TreeValue new_node;
		new_node.v.s = "real";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  | VOID {
    struct TreeValue new_node;
		new_node.v.s = "void";
		new_node.use = "string";
    $$ = create_node(new_node,TYPE_SPECIFIER,NULL,NULL,NULL,NULL); 
  }
  ;

assignation:
  id_declarator ASSIGNATOR expr {
      struct TreeValue empty_node; empty_node.use="none";
      $$ = create_node(empty_node,ASSIGNATION,$1,$3,NULL,NULL);
  }
  ;

constant:
  INT_VALUE { 
    struct TreeValue new_node;
    new_node.use = "int";
    new_node.v.i = yyval.intValue;
    $$ = create_node(new_node, CONSTANT, NULL, NULL, NULL, NULL);  
  }
  | REAL_VALUE { 
    struct TreeValue new_node;
    new_node.use = "real";
    new_node.v.r = yyval.realValue;
    $$ = create_node(new_node, CONSTANT, NULL, NULL, NULL, NULL); 
  } 
  | STRING_VALUE { 
    struct TreeValue new_node;
    new_node.use = "string";
    new_node.v.s = yyval.strValue;
    $$ = create_node(new_node, CONSTANT, NULL, NULL, NULL, NULL); 
  }
  | CHAR_VALUE { 
    struct TreeValue new_node;
    new_node.use = "char";
    new_node.v.c = yyval.charValue;
    $$ = create_node(new_node, CONSTANT, NULL, NULL, NULL, NULL); 
  }
  | BOOLEAN_VALUE { 
    struct TreeValue new_node;
    new_node.use = "bool";
    new_node.v.b = yyval.boolValue;
    $$ = create_node(new_node, CONSTANT, NULL, NULL, NULL, NULL); 
  }
  | NULL_VALUE { 
    struct TreeValue new_node;
    new_node.use = "null";
    $$ = create_node(new_node, CONSTANT, NULL, NULL, NULL, NULL); 
  }
  
expr: 
  constant { 
    struct TreeValue empty_node; empty_node.use=$1->val.use; $$ = create_node(empty_node, CONSTANT_EXPR, $1, NULL, NULL, NULL); 
  }
  | id_declarator { 
      struct TreeValue empty_node; 
      empty_node.use="none";
      $$ = create_node(empty_node,ID_EXPR,$1,NULL,NULL,NULL);
  }
  | '-' expr %prec UMINUS { 
    struct TreeValue empty_node; 
    empty_node.use=$2->val.use; 
    $$ = create_node(empty_node, OPPOSITE, $2, NULL, NULL, NULL); 
  }
  | expr '+' expr  { 
      struct TreeValue empty_node; 
      empty_node.use=$1->val.use; 
      $$ = create_node(empty_node, ADDITION, $1, $3, NULL, NULL); 
  }
  | expr '-' expr  { 
      struct TreeValue empty_node; 
      empty_node.use=$1->val.use; 
      $$ = create_node(empty_node, SOUSTRACTION, $1, $3, NULL, NULL); 
  }
  | expr '*' expr  { 
      struct TreeValue empty_node; 
      empty_node.use=$1->val.use; 
      $$ = create_node(empty_node, MULTIPLICATION, $1, $3, NULL, NULL); 
  }
  | expr '/' expr  { 
    if ($3->first->val.v.s != NULL 
              && (strcmp($3->first->val.use,"int") == 0 && $3->first->val.v.i == 0) 
              || (strcmp($3->val.use,"real") == 0 && $3->first->val.v.r == 0)) {
      yyerror("Trying to divide by 0.");
      exit(1);
    } else {
      struct TreeValue empty_node; 
      empty_node.use="real"; 
      $$ = create_node(empty_node, DIVISION, $1, $3, NULL, NULL); 
    }
  }
  | expr INF expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, INFERIOR, $1, $3, NULL, NULL); 
  }
  | expr AND expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, AND_OP, $1, $3, NULL, NULL); 
  }
  | expr OR expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, OR_OP, $1, $3, NULL, NULL); 
  }
  | NOT expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, NOT_OP, $2, NULL, NULL, NULL); 
  }
  | expr SUP expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, SUPERIOR, $1, $3, NULL, NULL); 
  }
  | expr SUPEQ expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, SUPERIOR_EQUAL, $1, $3, NULL, NULL); 
  }
  | expr INFEQ expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, INFERIOR_EQUAL, $1, $3, NULL, NULL); 
  }
  | expr NOTEQ expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, NOT_EQUAL, $1, $3, NULL, NULL); 
  }
  | expr EQ expr  { 
      struct TreeValue empty_node; 
      empty_node.use="bool"; 
      $$ = create_node(empty_node, EQUAL, $1, $3, NULL, NULL); 
  }
  | expr DIV expr  { 
    if ($3->first->val.v.s != NULL 
              && (strcmp($3->first->val.use,"int") == 0 && $3->first->val.v.i == 0) 
              || (strcmp($3->val.use,"real") == 0 && $3->first->val.v.r == 0)) {
      yyerror("Trying to divide by 0.");
      exit(1);
    } else {
      struct TreeValue empty_node; 
      empty_node.use="int";       
      $$ = create_node(empty_node, INT_DIVISION, $1, $3, NULL, NULL); 
    }
  }
  | expr MOD expr { 
    if ($3->first->val.v.s != NULL 
              && (strcmp($3->first->val.use,"int") == 0 && $3->first->val.v.i == 0) 
              || (strcmp($3->val.use,"real") == 0 && $3->first->val.v.r == 0)) {
      yyerror("Trying to divide by 0.");
      exit(1);
    } else {
      struct TreeValue empty_node; 
      empty_node.use="int"; 
      $$ = create_node(empty_node, MODULO, $1, $3, NULL, NULL); 
    }
  }
  | '(' expr ')'  { 
    struct TreeValue empty_node; 
    empty_node.use=$2->val.use; 
    $$ = create_node(empty_node, PARENTHESIS, $2, NULL, NULL, NULL); 
  }
  | ABS '(' expr ')' {
    struct TreeValue empty_node; 
    empty_node.use=$3->val.use; 
    $$ = create_node(empty_node, ABS_FUNC, $3, NULL, NULL, NULL);
  }
  | LOG '(' expr ')' {
      struct TreeValue empty_node; 
      empty_node.use="real"; 
      $$ = create_node(empty_node, LOG_FUNC, $3, NULL, NULL, NULL);
  }
  | LOG '(' expr COMMA expr ')' {
      struct TreeValue empty_node; 
      empty_node.use="real"; 
      $$ = create_node(empty_node, LOG_FUNC, $3, $5, NULL, NULL);
    
  }
  | EXP '(' expr ')' {
      struct TreeValue empty_node; 
      empty_node.use="real"; 
      $$ = create_node(empty_node, EXP_FUNC, $3, NULL, NULL, NULL);
  }
  ;

comment_block:
  COMMENT NEWLINE {
   struct TreeValue new_node;
    new_node.use = "string";
    new_node.v.s = yyval.strValue;
    $$ = create_node(new_node, COMMENT_BLOCK, NULL, NULL, NULL, NULL);
  }

stmt_terminator:
  TERMINATOR {}

ignore_newline:
  NEWLINE {}

%%

B_TREE create_node(struct TreeValue val, int case_identifier, B_TREE p1, B_TREE p2, B_TREE p3, B_TREE p4) {
  B_TREE t;
	t = (B_TREE)malloc(sizeof(TREE_NODE));
	t->val = val;
	t->nodeIdentifier = case_identifier;
	t->first = p1;
	t->second = p2;
	t->third = p3;
	t->fourth = p4;
	return (t);
}

int find_usage(B_TREE p,char *value[100], int i, char *use) {
  if(p == NULL)
    return i;
  
  //if the given node use is equivalent to the target one ("use"), we get the value of the node into the "value" variable
  //we then add 1 to the given index
  if(strcmp(p->val.use,use) == 0) {
    strcpy(value[i],p->val.v.s);
    i++;
  }

  i=find_usage(p->first,value,i,use);
  i=find_usage(p->second,value,i,use);
  i=find_usage(p->third,value,i,use);
  i=find_usage(p->fourth,value,i,use);
  return i;
}

void PrintTree(B_TREE t) {
	if(t==NULL)
		return; 
  if (t->nodeIdentifier < 11)
    /* 
      Correspond to nodes for which values are not relevant : 
      ID_EXPR,CONSTANT_EXPR, INFERIOR, SUPERIOR, SUPERIOR_EQUAL, INFERIOR_EQUAL, NOT_EQUAL, EQUAL, ABS_FUNC, LOG_FUNC, EXP_FUNC,
    */
    printf("No value | ");
  else {
    if(strcmp(t->val.use,"string")==0)
      printf("Value: %s | ",t->val.v.s);
    else if(strcmp(t->val.use,"identifier")==0)
      printf("Value: %s | ",t->val.v.s);
    else if(strcmp(t->val.use,"real")==0)
      printf("Value: %Lf | ",t->val.v.r);
    else if(strcmp(t->val.use,"int")==0)
      printf("Value: %d | ",t->val.v.i);
    else if(strcmp(t->val.use,"char")==0)
      printf("Value: %c | ",t->val.v.c);
    else if(strcmp(t->val.use,"bool")==0) {
      if (t->val.v.b == 0)
        printf("Value: False | ");
      else
        printf("Value: True | ");
    }
    else if(strcmp(t->val.use,"null")==0)
      printf("Value: NULL | ");
    else 
      printf("No value | ");
  }

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
  fprintf(stderr, "[ERROR]: %s\n", s);
  return 0;
}