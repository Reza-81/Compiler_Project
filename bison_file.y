// C declarations
%{
    void yyerror (char *s);
    int yylex();
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <string.h>

    const int max_arr_size = 30;

    void add(char * a, char * b, char * c);
    void sub(char * a, char * b, char * c);
    void multiply(char * a, char * b, char * c);
    void division(char * a, char * b, char * c);
    void print_OP(char a[][max_arr_size], char b[][max_arr_size], char c[][max_arr_size], char operation);

    int node_counter = 1;
%}

// define the data types of tokens
%union{
    char num[2][30 /*max size of array*/]; // first row is for value. second row is for node number (Tx)
}

// tokens
%token<num> digit
%token ADD
%token SUB
%token MUL
%token DIV
%token EQ
%token PAR_1
%token PAR_2

// start symbol
%start s

// none-terminals type
%type <num> expr
%type <num> term
%type <num> factor

// productions and semantic actions
%%
s: expr EQ
      ;

expr: expr ADD term {add($1[0], $3[0], $$[0]); print_OP($1, $3, $$, '+');}| // add operation
      expr SUB term {sub($1[0], $3[0], $$[0]); print_OP($1, $3, $$, '-');}| // subtract operation
      term          {strcpy($$[0], $1[0]); strcpy($$[1], $1[1]);} // if you dont specify a semantic action, the default is $$ = $1
      ;

term: term MUL factor {multiply($1[0], $3[0], $$[0]); print_OP($1, $3, $$, '*');}| //multiply operation
      term DIV factor {division($1[0], $3[0], $$[0]); print_OP($1, $3, $$, '/');}| //division operation
      factor          {strcpy($$[0], $1[0]); strcpy($$[1], $1[1]);}
      ;

factor: digit            {strcpy($$[0], $1[0]); strcpy($$[1], $1[1]);}| // digit
        PAR_1 expr PAR_2 {strcpy($$[0], $2[0]); strcpy($$[1], $2[1]);}  // parenthesis
        ;
%%

// function definitions
// ==================== ADD operation ====================
void add(char * a, char * b, char * c){
    /* find the elements in b that are not in a. then append them to a. */
    int flag_found;
    int c_index;

    strcpy(c, a); // copy a to c

    for (c_index = 0; c[c_index] != 0; c_index++){} // finding the len of c

    for (int b_index = 0; b[b_index] != 0; b_index++) { // select charater
        flag_found = 0;
        for (int a_index = 0; a[a_index] != 0; a_index++) { // check if the character exist
            if (b[b_index] == a[a_index]) {
                flag_found = 1;
                break;
            }
        }
        // If the character is not found in c, apend it
        if (!flag_found) {
            c[c_index] = b[b_index];
            c_index++;
        }
    }
    c[c_index] = 0;
}
// ==================== SUB operation ====================
void sub(char * a, char * b, char * c){
    /* find the elements in b that are in a. then delete from a. */
    // printf("alan to subim");
    int c_index = 0;
    int flag_found;

    for (int a_index = 0; a[a_index] != 0; a_index++){
        flag_found = 0;
        for (int b_index = 0; b[b_index] != 0; b_index++){
            if (a[a_index] == b[b_index]){
                flag_found = 1;
                break;
            }
        }
        if (!flag_found){
            c[c_index] = a[a_index];
            c_index++;
        }
    }
    c[c_index] = 0;
}
// ==================== MUL operation ====================
void multiply(char * a, char * b, char * c){
    /* calculate the sumation of digits in b until you get a number with one digit.
       if it is not in a. then append it to a. */
    int sum = 0;
    int num = 0;
    char temp[2];
    
    // calculate the sumation
    for (int b_index = 0; b[b_index] != 0; b_index++){
        sum += b[b_index] - '0';
    }
    while (num > 0 || sum >= 10) {
        if (num == 0) {
            num = sum;
            sum = 0;
        }
        sum += num % 10;
        num /= 10;
    }
    temp[0] = sum + '0';
    temp[1] = 0;
    add(a, temp, c);
}
// ==================== DIV operation ====================
void division(char * a, char * b, char * c){
    /* calculate the sumation of digits in b until you get a number with one digit.
       if it is in a. then delete it from a. */
    int sum = 0;
    int num = 0;
    char temp[2];
    
    // calculate the sumation
    for (int b_index = 0; b[b_index] != 0; b_index++){
        sum += b[b_index] - '0';
    }
    while (num > 0 || sum >= 10) {
        if (num == 0) {
            num = sum;
            sum = 0;
        }
        sum += num % 10;
        num /= 10;
    }
    temp[0] = sum + '0';
    temp[1] = 0;
    sub(a, temp, c);
}
// ==================== print three-address code ====================
void print_OP(char a[][max_arr_size], char b[][max_arr_size], char c[][max_arr_size], char operation){
    if (a[1][0] == 0){
        if (b[1][0] == 0){
            printf("T%d=%s%c%s;\n", node_counter, a[0], operation, b[0]);
        }
        else{
            printf("T%d=%s%cT%s;\n", node_counter, a[0], operation, b[1]);
        }
    }
    else{
        if (b[1][0] == 0){
            printf("T%d=T%s%c%s;\n", node_counter, a[1], operation, b[0]);
        }
        else{
            printf("T%d=T%s%cT%s;\n", node_counter, a[1], operation, b[1]);
        }
    }
    printf("T%d=%s;\n", node_counter, c[0]);
    sprintf(c[1], "%d", node_counter);
    node_counter++;
}

// print the compiler error
void yyerror (char *s) {fprintf (stderr, "%s\n", s);}

// call the compiler
int main(){

    printf("Compiler is running. Enter your input: \n");

    yyparse();

    return 0;
}