CC=/usr/bin/cc

all:  bison-config flex-config nutshell

bison-config:
	bison -d parser.y

flex-config:
	flex scanner.l

nutshell: 
	$(CC) main.c parser.tab.c lex.yy.c -o main

clean:
	rm parser.tab.c parser.tab.h lex.yy.c main