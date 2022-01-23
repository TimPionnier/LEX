#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void write_string_in_python_file(char *s);
void write_basic_data_type(B_TREE t);
void append_tab(int nb);
void write_real_in_python_file(long double realValue);
void write_int_in_python_file(int intValue);
void print_function_parameters(B_TREE t);

void parse_tree_to_python(B_TREE t, int stmt_block_counter)
{
    // TODO(): check func call

    if (t == NULL)
        return;

    if (strcmp(labels[(t->nodeIdentifier)], "COMMENT_BLOCK") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        write_string_in_python_file("#");
        char *p = t->val.v.s;
        p++;
        p[strlen(p) - 1] = 0;
        write_string_in_python_file(p);
        write_string_in_python_file("\n");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "PARENTHESIS") == 0)
    {
        write_string_in_python_file("(");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(")");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "OPPOSITE") == 0)
    {
        write_string_in_python_file("-");
        parse_tree_to_python(t->first, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "ADDITION") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" + ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "SOUSTRACTION") == 0)
    {
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" - ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "MULTIPLICATION") == 0)
    {
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" * ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "DIVISION") == 0)
    {
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" / ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "INT_DIVISION") == 0)
    {
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" // ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "MODULO") == 0)
    {
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" % ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "EXP_FUNC") == 0)
    {
        write_string_in_python_file("math.exp(");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(")");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "LOG_FUNC") == 0)
    {
        write_string_in_python_file("math.log(");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(") ");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "ABS_FUNC") == 0)
    {
        write_string_in_python_file("abs(");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(") ");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "SUPERIOR") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" > ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "INFERIOR") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" < ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "SUPERIOR_EQUAL") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" >= ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "INFERIOR_EQUAL") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" <= ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "NOT_EQUAL") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" != ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "EQUAL") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" == ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "AND_OP") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file("and ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "OR_OP") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file("or ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "NOT_OP") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        write_string_in_python_file("not(");
        parse_tree_to_python(t->first, stmt_block_counter);
        parse_tree_to_python(t->second, stmt_block_counter);
        write_string_in_python_file(")");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "CONSTANT_EXPR") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "CONSTANT") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        write_basic_data_type(t);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "DECLARATOR_LIST") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        if (strcmp(t->first->val.use, "identifier") == 0)
        {
            write_string_in_python_file(" = ");
            write_string_in_python_file("None");
            write_string_in_python_file("\n");
        }
        else
        {
            parse_tree_to_python(t->second, stmt_block_counter);
            write_string_in_python_file(" = ");
            write_string_in_python_file("None");
            write_string_in_python_file("\n");
        }
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "DECLARATION_LIST") == 0)
    {
        printf("nothing written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        if (t->second != NULL)
        {
            write_string_in_python_file(",");
            parse_tree_to_python(t->second, stmt_block_counter);
        }
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "ASSIGNATION") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" = ");
        parse_tree_to_python(t->second, stmt_block_counter);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "ID") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        write_string_in_python_file(t->val.v.s);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "IF_ELSE_STMT") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        append_tab(stmt_block_counter);
        write_string_in_python_file("if ");

        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(":\n");
        parse_tree_to_python(t->second, stmt_block_counter + 1);
        if (t->third != NULL)
        {
            append_tab(stmt_block_counter);
            write_string_in_python_file("else");
            write_string_in_python_file(":\n");
            parse_tree_to_python(t->third, stmt_block_counter + 1);
        }
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "FOR_LOOP") == 0)
    {
        append_tab(stmt_block_counter);
        write_string_in_python_file("for ");
        parse_tree_to_python(t->first->first, stmt_block_counter);
        write_string_in_python_file(" in range(");
        parse_tree_to_python(t->first->second, stmt_block_counter);
        write_string_in_python_file(",");
        parse_tree_to_python(t->second, stmt_block_counter);
        write_string_in_python_file(")");
        write_string_in_python_file(":\n");
        ;
        parse_tree_to_python(t->third, stmt_block_counter + 1);
    }

    else if (strcmp(labels[(t->nodeIdentifier)], "WHILE_LOOP") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        // while
        append_tab(stmt_block_counter);
        write_string_in_python_file("while ");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(":\n");
        parse_tree_to_python(t->second, stmt_block_counter + 1);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "WRITE_STMT") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        append_tab(stmt_block_counter);
        write_string_in_python_file("print(");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(")\n");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "READ_STMT") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        write_string_in_python_file("\n");
        append_tab(stmt_block_counter);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file(" = input(\"Waiting for user input... \" )\n");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "FUNC_STMT") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        append_tab(stmt_block_counter);
        write_string_in_python_file("def ");
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file("(");
        print_function_parameters(t->second);
        write_string_in_python_file(")");
        write_string_in_python_file(":\n");
        parse_tree_to_python(t->fourth, stmt_block_counter + 1);
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "STMT") == 0)
    {
        printf("nothing written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        append_tab(stmt_block_counter);
        parse_tree_to_python(t->first, stmt_block_counter);
        write_string_in_python_file("\n");
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "STMT_BLOCK_RETURN") == 0)
    {
        parse_tree_to_python(t->first, stmt_block_counter);
        append_tab(stmt_block_counter);
        write_string_in_python_file("return ");
        parse_tree_to_python(t->second, stmt_block_counter);
        write_string_in_python_file("\n");
    }
    else
    {
        printf("nothing written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        parse_tree_to_python(t->first, stmt_block_counter);
        parse_tree_to_python(t->second, stmt_block_counter);
        parse_tree_to_python(t->third, stmt_block_counter);
        parse_tree_to_python(t->fourth, stmt_block_counter);
    }
}

void append_tab(int nb)
{
    for (int i = 0; i < nb; i++)
    {
        write_string_in_python_file("\t");
    }
}

void write_string_in_python_file(char *s)
{
    FILE *fptr;
    fptr = fopen("./code.py", "ab");

    if (fptr == NULL)
    {
        printf("Error!");
        exit(1);
    }
    fprintf(fptr, "%s", s);
    fclose(fptr);
}

void write_real_in_python_file(long double realValue)
{
    FILE *fptr;
    fptr = fopen("./code.py", "ab");

    if (fptr == NULL)
    {
        printf("Error!");
        exit(1);
    }
    fprintf(fptr, "%Lf", realValue);
    fclose(fptr);
}

void write_basic_data_type(B_TREE t)
{
    if (strcmp(t->val.use, "real") == 0)
    {
        write_real_in_python_file(t->val.v.r);
    }
    else if (strcmp(t->val.use, "int") == 0)
    {
        write_int_in_python_file(t->val.v.i);
    }
    else if (strcmp(t->val.use, "bool") == 0)
    {
        write_string_in_python_file(t->val.v.b ? "True" : "False");
    }
    else if (strcmp(t->val.use, "string") == 0)
    {
        write_string_in_python_file(t->val.v.s);
    }
}

void print_function_parameters(B_TREE t)
{
    if (strcmp(labels[(t->nodeIdentifier)], "DECLARATION_LIST") == 0)
    {
        printf("nothing written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        print_function_parameters(t->first);
        if (t->second != NULL)
        {
            write_string_in_python_file(",");
            print_function_parameters(t->second);
        }
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "DECLARATOR_LIST") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        print_function_parameters(t->first);
        if (t->second != NULL)
        {
            write_string_in_python_file(",");
            print_function_parameters(t->second);
        }
    }
    else if (strcmp(labels[(t->nodeIdentifier)], "ID") == 0)
    {
        printf("written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        write_string_in_python_file(t->val.v.s);
    }
    else
    {
        printf("nothing written for nodeIdentifier: %s\n", labels[(t->nodeIdentifier)]);
        print_function_parameters(t->first);
    }
}

void write_int_in_python_file(int intValue)
{
    FILE *fptr;
    fptr = fopen("./code.py", "ab");

    if (fptr == NULL)
    {
        printf("Error!");
        exit(1);
    }
    fprintf(fptr, "%d", intValue);
    fclose(fptr);
}
