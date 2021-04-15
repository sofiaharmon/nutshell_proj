#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vars.h"
#include <unistd.h>
#include <limits.h>
char *getcwd(char *buf, size_t size);

int main()
{
    init();
    system("clear");

    while (1)
    {
        printPrompt();       
        yyparse();
    }

    return 0;
}

void printPrompt()
{
    printf("[%s]>> ", varTable.word[2]);
    return;
}

void init()
{
    aliasIndex = 0;
    varIndex = 0;
    cmdFill = 0;
    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    strcpy(aliasTable.name[aliasIndex], ".");
    strcpy(aliasTable.word[aliasIndex], cwd);
    aliasIndex++;

    char *pointer = strrchr(cwd, '/');
    while (*pointer != '\0')
    {
        *pointer = '\0';
        pointer++;
    }
    strcpy(aliasTable.name[aliasIndex], "..");
    strcpy(aliasTable.word[aliasIndex], cwd);
    aliasIndex++;

    return;
}
