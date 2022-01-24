#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* symbol table management */


#define IDLENGTH	15
#define SYMTABSIZE 997

char scope[16];
int yyerror(char *s);


struct node
{
	char *name;
	char *type;
};

struct node symtab[SYMTABSIZE];

struct scope_symtab {
	struct node *prec[SYMTABSIZE];
	struct node symtab[SYMTABSIZE];
};

int hash(char *str, int i)
{
	unsigned long hash = 5381;
	int c;

	while ((c = *str++) != 0)
		hash = ((hash << 4) + hash) + c; /* hash * 33 + c */

	return ((int)((hash + i) % SYMTABSIZE));
}

int hash_search(char *str)
{
	int i = 0;
	int j = hash(str, i);
	while ((i < SYMTABSIZE) && (strcmp(symtab[j].name, "NULL") != 0))
	{
		if (strcmp(symtab[j].name, str) == 0)
		{
			return j;
		}
		i++;
		j = hash(str, i);
	}
	return (-1);
}

int hash_insert(char *str, char *typ)
{
	int i = 0;
	int j;
	while (i < SYMTABSIZE)
	{
		j = hash(str, i);
		if (strcmp(symtab[j].name, "NULL") == 0)
		{
			strcpy(symtab[j].name, str);
			symtab[j].type = (char *)malloc(10 * sizeof(char));
			strcpy(symtab[j].type, typ);

			return j;
		}
		i++;
	}
	return (-1);
}

void define_symtab_scopes(B_TREE t, char *current_scope)
{
	if (t == NULL)
		return;

	if (strcmp(labels[(t->nodeIdentifier)], "FUNC_STMT") == 0)
	{
		define_symtab_scopes(t->first, current_scope);
		strcpy(scope, "local_");
		strcat(scope, t->first->val.v.s);
		define_symtab_scopes(t->second, scope);
	}
	else if (strcmp(labels[(t->nodeIdentifier)], "ID") == 0)
	{
		hash_edit_scope(t->val.v.s, current_scope);
	} else {
		define_symtab_scopes(t->first, current_scope);
		define_symtab_scopes(t->second, current_scope);
		define_symtab_scopes(t->third, current_scope);
		define_symtab_scopes(t->fourth, current_scope);
	}
}

void check_symtab_scopes(){
	int i,j;
	for (i = 0; i < SYMTABSIZE; i++)
	{
		if (strcmp(symtab[i].name, "NULL") != 0){
			for (j = 0; j < SYMTABSIZE; j++){
				if (i != j && strcmp(symtab[i].name, symtab[j].name) == 0){
					char message[35+IDLENGTH] = "Variable ";
        			strcat(message,symtab[i].name);
        			strcat(message," has already been declared.");
        			yyerror(message);
        			exit(1);
				}
			}
		}
	}
	printf("All symbols are properly declared");
}

void init_symtable()
{
	int k;
	for (k = 0; k < SYMTABSIZE; k++)
	{
		symtab[k].name = (char *)malloc(100 + 1);
		strcpy(symtab[k].name, "NULL");
	}
	return;
}

void print_table()
{
	int i;
	printf("\nSYMBOL TABLE\n");
	printf("-------------------------------------------------\n");
	printf("|INDEX\t|NAME\t|DATATYPE\t|SCOPE\t\t|\n");
	printf("-------------------------------------------------\n");
	for (i = 0; i < SYMTABSIZE; i++)
	{
		if (strcmp(symtab[i].name, "NULL") != 0)
			printf("|%d\t|%s\t|%s\t\t|%s\t\t|\n", i, symtab[i].name, symtab[i].type, symtab[i].scope);
	}
	printf("-------------------------------------------------\n");
	return;
}