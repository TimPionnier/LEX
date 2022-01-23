#include<stdio.h>
#include<stdlib.h>
#include<string.h>

/* symbol table management */


#define SYMTABSIZE 997
struct node{
	char *name;
	char *type;
	char *scope; //possible values are "global" or "local" or "enclosing"
};

struct node symtab[SYMTABSIZE]; 

int hash(char *str,int i)
{
    unsigned long hash = 5381;
    int c;

    while ((c = *str++) != 0)
        hash = ((hash << 4) + hash) + c; /* hash * 33 + c */

    return ((int)((hash+i)%SYMTABSIZE));
}

int hash_search(char *str) {
	int i=0;
	int j=hash(str,i);
	while((i<SYMTABSIZE) && (strcmp(symtab[j].name,"NULL")!=0)) {
		if(strcmp(symtab[j].name,str)==0) {
			return j;
		}
		i++;
		j=hash(str,i);
	}
	return (-1);
}

int hash_insert(char *str,char *typ,char *scope) {
	if(hash_search(str)==-1) {
		int i=0;
		int j;
		while(i<SYMTABSIZE) {
			j=hash(str,i);
			if(strcmp(symtab[j].name,"NULL")==0) {
				strcpy(symtab[j].name,str);
				symtab[j].type=(char*)malloc(10*sizeof(char));
				strcpy(symtab[j].type,typ);
				symtab[j].scope=(char*)malloc(9*sizeof(char)); //maximum lenght scope name is "enclosing"
				strcpy(symtab[j].scope,scope);
				return j;
			}
			i++;
		} 
	}
	return (-1);
}

void init_symtable() {
	int k;
	for(k=0;k<SYMTABSIZE;k++) {
		symtab[k].name=(char *)malloc (100 + 1);
		strcpy(symtab[k].name,"NULL");
	}
	return ;
}

void print_table() {
	int i;
	printf("\nSYMBOL TABLE\n");
	printf("-------------------------------------------------\n");
	printf("|INDEX\t|NAME\t|DATATYPE\t|SCOPE\t\t|\n");
	printf("-------------------------------------------------\n");
	for(i=0;i<SYMTABSIZE;i++) {
		if(strcmp(symtab[i].name,"NULL")!=0)
			printf("|%d\t|%s\t|%s\t\t|%s\t\t|\n",i,symtab[i].name,symtab[i].type,symtab[i].scope);
	}
	printf("-------------------------------------------------\n");
    return;
}