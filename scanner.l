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
STDERR          [2]/[>]

%x string_condition
%x env_condition
%x err_condition

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

<err_condition>[>]              {}
<err_condition>{CHAR}+          { yylval.string = strdup(yytext); return ERR; }
<err_condition>[ ]|[\t]|[\n]    {BEGIN(INITIAL);}

[ ]		            { }
bye                 { return BYE; }
cd		            { return CD; }
alias		        { return ALIAS; }
unalias             { return UNALIAS; }
"\n"		        { return END; }
[\"]                { BEGIN(string_condition); }
[~]                 { char *yycopy = strdup( subEnv("HOME") );
                      for ( int i = strlen(subEnv("HOME")) - 1; i >= 0; --i ) {
                        unput( yycopy[i] );
                      }
                      free( yycopy );
                    }
[2][>]{ANYCHAR}+    { yylval.string = strdup(yytext + 2); return ERR; }
[$]/[\{]            {BEGIN(env_condition);}
{CHAR}+             {if(ifAlias(yytext)) {
                        printf("yytext before sub: %s\n", yytext);
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    } else {
                        //printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };
                    }
{FILE_OUT}          { return OUT; }
{FILE_IN}           { return IN; }
{FILE_OUT}+         { return APPEND; }

%%