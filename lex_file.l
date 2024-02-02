/* C declarations */
%{  
    #include <stdio.h>	
    #include <string.h>
    #include "bison_file.tab.h"
%}

/* rules */
%%
[0-9]{1,10} {strcpy(yylval.num[0], yytext); yylval.num[1][0] = 0; return digit;}
[*] {return MUL;}
[/] {return DIV;}
[+] {return ADD;}
[-] {return SUB;}
[=] {return EQ;}
[(] {return PAR_1;}
[)] {return PAR_2;}
[\n] {return 0;}
[ ] {}
. {printf("%s is not a valid character.\n", yytext);}
%%

int yywrap(){}