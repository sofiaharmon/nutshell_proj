#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    printf("test file:\n");
    
    for (int i = 0; i < argc; i++) {
        printf("arg[%d]: %s\n", i, argv[i]);
    }

    fprintf( stderr, "error msg\n");

    return 1;
}