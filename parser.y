%{

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/wait.h>
#include "stdbool.h"
#include "vars.h"

int yylex();
int yyerror(char *s);
int runCD(char* arg);
int runLS();
int runSetAlias(char *name, char *word);
int listAlias();
int runUnalias(char *arg); 
int createTable(char *arg);
int addOutFile(char *fileName);
int addInFile(char *fileName);
int executeCmd();
int clrTable();
%}

%union {char *string;}

%start cmd_line
%token <string> ALIAS BYE CD END IN LS OUT STRING UNALIAS

%%

cmd_line    :
    BYE END                         {exit(1); return 1;}
    | CD STRING END                 {runCD($2); return 1;}
    | LS END                        {runLS(); return 1;}
    | ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
    | ALIAS END                     {listAlias(); return 1;}
    | UNALIAS STRING END            {runUnalias($2); return 1;}
    | STRING                        {createTable($1); yyparse(); return 1;}
    | OUT STRING                    {addOutFile($2); yyparse(); return 1;}
    | IN STRING                     {addInFile($2); yyparse(); return 1;}
    | END                           {executeCmd(); clrTable(); return 1;}

%%

int yyerror(char *s) {
    //printf("%s\n", s);
    return 0;
}

int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			strcpy(aliasTable.word[0], varTable.word[0]);
			strcpy(aliasTable.word[1], varTable.word[0]);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
				*pointer ='\0';
				pointer++;
			}
		}
		else {
			//strcpy(varTable.word[0], varTable.word[0]); // fix
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(aliasTable.word[0], arg);
			strcpy(aliasTable.word[1], arg);
			strcpy(varTable.word[0], arg);
			char *pointer = strrchr(aliasTable.word[1], '/');
			while(*pointer != '\0') {
			*pointer ='\0';
			pointer++;
			}
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
	return 1;
}

int runSetAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int runLS() {
    
    struct dirent **namelist;
    int n;

    n = scandir(".", &namelist, NULL, alphasort);

    if (n == -1) {
        perror("scandir");
        exit(EXIT_FAILURE);
    }

    while (n--) {
        printf("%s\n", namelist[n]->d_name);
        free(namelist[n]);
    }
    free(namelist);


    return 1;
}

int listAlias() {

    for (int i = 0; i < aliasIndex; i++) {
        printf("alias %s = \"%s\"\n", aliasTable.name[i], aliasTable.word[i]);
    }

    return 1;
}

int runUnalias(char *arg) {
    int j = 0;
    bool found = false;
    for (int i = 0; i < aliasIndex; i++) {
        if (strcmp(aliasTable.word[i], arg) == 0) {
            j = i;
            found = true;
        }
    }
    
    if (found) {
        for (j; j < aliasIndex - 2; j++) {
            strcpy(aliasTable.name[j], aliasTable.name[j+1]);
            strcpy(aliasTable.word[j], aliasTable.word[j+1]);
        }

        aliasIndex--;
    }
    else {
        printf("Error: \"%s\" not found\n", arg);
    }
    return 1;
}

int createTable(char* arg) {
    
    if (cmdFill == 0) {
        strcpy(cmdTable.cmdName, arg);
        cmdFill = 1;
        strcpy(cmdTable.args[0], arg);
        cmdTable.argCount = 1;
        cmdTable.isIn = 0;
        cmdTable.isOut = 0;
    }
    else {
        strcpy(cmdTable.args[cmdTable.argCount], arg);
        cmdTable.argCount += 1;
    }
    
    return 1;
}

int addOutFile(char *fileName) {
    if (fileName) {
        cmdTable.isOut = 1;
        strcpy(cmdTable.fileOut, fileName);
    }

    return 1;
}

int addInFile(char *fileName) {
    if (fileName) {
        cmdTable.isIn = 1;
        strcpy(cmdTable.fileIn, fileName);
    }

//    in = dup(STDIN_FILENO);

    return 1;
}

int executeCmd() {
    
    if (cmdFill == 1) {
        if (fork() == 0) {
            
            if(cmdTable.isOut == 1) {
                int fd;

                fd = creat(cmdTable.fileOut, 0644);
                if (fd < 0) {
                    printf("error opening %s\n", cmdTable.fileOut);
                }
                dup2(fd, STDOUT_FILENO);
            
                if (fd != STDOUT_FILENO) {
                    close(fd);
                }
            }

            if(cmdTable.isIn == 1) {
                int fd0 = open(cmdTable.fileIn, O_RDONLY);
                dup2(fd0, STDIN_FILENO);
                close(fd0);
                cmdTable.isIn = 0;
                yyparse();
            }

            //for the case of inside the yyparse(), to avoid infinite loop
            if (cmdFill == 0) {
                exit(EXIT_FAILURE);
            }

            char *newArg[100];
            for (int i = 0; i < cmdTable.argCount; i++) {
            newArg[i] = cmdTable.args[i];
            }
            newArg[cmdTable.argCount] = NULL;

            char *env_args[] = { NULL };

            int check = execve(cmdTable.cmdName, newArg, env_args);
            if (check < 0) {
                perror("execve");
                printf("%s: No such file or directory\n", cmdTable.cmdName);
                exit(EXIT_FAILURE);
            }
        }
        else {
            wait(NULL);
            
        }
    }
    return 1;
}

int clrTable() {
    if (cmdFill == 1) {
        cmdFill = 0;
        strcpy(cmdTable.cmdName, "");

        for (int i = 0; i < cmdTable.argCount; i++) {
            strcpy(cmdTable.args[i], "");
        }
        cmdTable.argCount = 0;
        cmdTable.isOut = 0;
        cmdTable.isIn = 0;
        strcpy(cmdTable.fileIn, "");
        strcpy(cmdTable.fileOut, "");
    }
    return 1;
}