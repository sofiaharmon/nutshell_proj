%{
#include "parser.tab.h"
#include <string.h>
#include "vars.h"
#include <stdbool.h>

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}
char* subEnv(char* var){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], var) == 0) {
            return varTable.word[i];
        }
    }
    return var;
}
%}

%array
%option noyywrap

CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR         [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*
PIPE            [|]
FILE_OUT        [>]
FILE_IN         [<]
BACKGROUND      [&]

%x string_condition
%x env_condition

%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]           {BEGIN(INITIAL);}

<env_condition>[\{]              { }
<env_condition>{ANYCHAR}+        { yylval.string = strdup(subEnv(yytext)); }
<env_condition>[\}]              {  char *yycopy = strdup( yylval.string );
                                    for ( int i = strlen(yylval.string) - 1; i >= 0; --i ) {
                                        unput( yycopy[i] );
                                    }
                                    free( yycopy );
                                    BEGIN(INITIAL);
                                }

[ ]		            { }
bye                { return BYE; }
cd		            { return CD; }
ls                  { return LS; }
alias		        { return ALIAS; }
unalias             { return UNALIAS; }
"\n"		        { return END; }
[\"]                 { BEGIN(string_condition); }
[$]                 {BEGIN(env_condition);}
{CHAR}+              {if(ifAlias(yytext)) {
                        printf("yytext before sub: %s\n", yytext);
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    } else {
                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };
                     }
%%