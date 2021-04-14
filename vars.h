

struct evTable {
   char var[128][100];
   char word[128][100];
};
struct aTable {
	char name[128][100];
	char word[128][100];
};
struct cTable {
    char cmdName[100];
    int argCount;
    char args[128][100];
    int isIn;
    int isOut;
    char fileIn[100];
    char fileOut[100];
};

struct evTable varTable;
struct aTable aliasTable;
struct cTable cmdTable;

int aliasIndex, varIndex, cmdFill;
int in;
char* subAliases(char* name);
void printPrompt();
void init();