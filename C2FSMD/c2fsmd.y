/*******************************************************************************
*  Name.......: c2fsmd.y                                                                                         *
*                                                                                                                            *
*  Description: parser to translate a C language code into a                              *
*               Finite State Machine with Datapath                                                   *
*                  Datapath representer in normalized expressions                            *
*                                                                                                                            *
*******************************************************************************/


%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include "header.h"

//#define DOTTY

/*
#ifdef DOTTY

	printf("Inside coditional compilation part\n");

#endif
*/

int *errP;
int yylex (void);
void yyerror(char const *s);
symtab *current_table;
int size,size1,size2;
int temp_int;
int state_count=1;
int state_rcnt=MAXSTATES-1;
char comments[MAXSTATES][50];
int prev_state=0,i=0,print_count;
int vartype,x;
//int lineno;
char *data;
char *temps;
char *printer;
NC *tee;
FSMD *c2f;
symtab *current_table;
TRANSITION_ST *transts;
p_lisT *tmp,*tmp1;
NODE_ST *st;
DATA_TRANS *transdata;
DT_LIST *dtlst;
LIST *lst1,*rtrn,*rtrn1;
int input_count=0;
int output_count=0;

loopi *l1,*l2;
int loop_count=0;

#ifdef DOTTY
char *colors[]={"black","magenta","chocolate","darkgreen","dodgerblue","firebrick","darkviolet"};
char *shapes[]={"record","box"};

char **string_clusters;
int **loops;

int if_count=0;
int ifel_count=0;
int loopl_count=0;
#endif

#define YYDEBUG 1
%}

%union {
char *str;
int integer;
float real;
prnsS prns;
typelS typel;
unopS unop;
ptrcntS ptrcnt;
dclrnS dclrn;
expresoS exprso;
exprsnS exprsn;
dtlsS dtls;
nclsS ncls;
epxrsstsS exprsSTS;
p_lisT p_l;
}


%token <str> STOR_CONSTANT <str> IDENTIFIER <str> CONSTANT <str> FLOAT_CONSTANT <str> STRING_LITERAL SIZEOF
// %token <str> NEW_LINE
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME
%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN MAIN

%type <typel> cnst
%type <p_l> parameter_declaration
%type <p_l> parameter_list
%type <p_l> parameter_type_list
%type <exprso> primary_expression
%type <exprso> postfix_expression
%type <exprso> unary_expression
%type <unop> unary_operator
%type <unop> assignment_operator
%type <exprso> cast_expression
%type <exprso> multiplicative_expression
%type <exprso> additive_expression
%type <exprso> shift_expression
%type <exprso> relational_expression
%type <exprso> equality_expression
%type <exprso> and_expression
%type <exprso> exclusive_or_expression
%type <exprso> inclusive_or_expression
%type <exprso> logical_or_expression
%type <exprso> logical_and_expression
%type <exprso> conditional_expression
%type <exprsn> assignment_expression
%type <exprsn> argument_expression_list
%type <exprso> constant_expression
%type <exprsn> expression
%type <dclrn> declaration
%type <typel> declaration_specifiers
%type <typel> type_specifier
%type <dtls> init_declarator_list
%type <dtls> init_declarator
%type <ncls> declarator
%type <ncls> direct_declarator
%type <ncls> initializer
%type <ncls> initializer_list
%type <ptrcnt> pointer
%type <prns> statement
%type <prns> jump_statement
%type <prns> compound_statement
%type <prns> declaration_list
%type <prns> statement_list
%type <prns> selection_statement
%type <prns> iteration_statement
%type <exprsSTS> expression_statement



%left LEFT_OP RIGHT_OP
%left LEFT_ASSIGN RIGHT_ASSIGN
%left ADD_ASSIGN SUB_ASSIGN
%left MUL_ASSIGN DIV_ASSIGN
%left OR_OP
%left AND_OP
%left EQ_OP NE_OP
%left "<" LE_OP ">" GE_OP
%left "+" "-"
%left "*" "/" "%"
%left INC_OP DEC_OP "!" UNEG UPOS
%start translation_unit
%%

cnst
	: CONSTANT				{	sprintf($$.str,"%s",$1);$$.vart=Int;	}
	| FLOAT_CONSTANT		{	sprintf($$.str,"%s",$1);$$.vart=Float;	}
	| STOR_CONSTANT		{	strcpy($$.str,$1);$$.vart=Stor;	}
	;

primary_expression
	: IDENTIFIER			{ 		printf("** Parser : identifier found in expression %s\n",$1);
								//$$.str=$1;
								$$.NCell=create_term($1);
								$$.DTr=NULL;
								$$.inc=0;
							}
	| cnst					{ 	//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s",$1.str);
								$$.NCell=create_NC();
								$$.NCell->type='C';
								$$.NCell->inc=fvalue($1.str,$1.vart);
								$$.DTr=NULL;
								$$.inc=0;
							}
	| STRING_LITERAL		{ 	//$$.str=$1;
								$$.NCell=NULL;
								/*varying*/
								$$.DTr=NULL;
								$$.inc=0;
							}
	| '(' expression ')'			{ 	//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"(%s)",$2.str);
								$$.NCell=$2.NCell;
								if($2.DTL==NULL) $$.DTr=NULL;
								else {
								while($2.DTL->next!=NULL)
									$2.DTL=$2.DTL->next;
								$$.DTr=$2.DTL->trans;
								}
								$$.inc=$2.inc;
							}
	;

postfix_expression
	: primary_expression		{ 		//$$.str=$1.str;
									$$.NCell=$1.NCell;
									$$.DTr=$1.DTr;
									$$.inc=$1.inc;
								}
	| postfix_expression '[' expression ']'	{
									//$$.str=(char*)malloc(40*sizeof(char));
									//sprintf($$.str,"%s[%s]",$1.str,$3.str);
									$$.NCell=$1.NCell;
								if($1.NCell->link->type!='A'){
									$1.NCell->link->type='A';
									$1.NCell->link->link=$3.NCell;
									}
								else {
									$1.NCell=$1.NCell->link->link;
									while($1.NCell->list!=NULL)
									   $1.NCell=$1.NCell->list;
									$1.NCell->list=$3.NCell;
									}
									if($3.DTL!=NULL)
									$$.DTr=$3.DTL->trans;
									else $$.DTr=NULL;
									$$.inc=0;
								}
	| postfix_expression '(' ')'	{
								//$$.str=$1.str;
								//strcat($$.str,"()");
								if($1.NCell->type != 'U'){
								printf("Error please check in line number : %s\n",line_count(0));
								printf("Possible function name and a declared variable match \n");
								exit(1); 
								}
								// printf("Ok as of now\n");exit(1);
								$1.NCell->type = 'f';
							}
	| postfix_expression '(' argument_expression_list ')'
							{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s(%s)",$1.str,$3.str);
								if($1.NCell->type != 'U'){
								printf("Error please check in line number : %s\n",line_count(0));
								printf("Possible function name and a declared variable match \n");
								exit(1); 
								}
								// printf("Ok as of now\n");exit(1);
								$1.NCell->type = 'f';
								$$.NCell=$1.NCell;
								$1.NCell->link=$3.NCell;
								$$.DTr=NULL;
							}
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP	{ 		//$$.str=(char*)malloc(40*sizeof(char));
									//sprintf($$.str,"%s++",$1.str);
									tee=create_NC();
									tee->type='S';
									tee->inc=ADD;
									tee->link=copy_NC($1.NCell);
									tee->link->list=create_NC();
									tee->link->list->type='C';
									tee->link->list->inc=1;
									$$.DTr=create_DT($1.NCell,tee);
									$$.NCell=$1.NCell;
									$$.inc=1+$1.inc;
								}
	| postfix_expression DEC_OP	{ 		//$$.str=$1.str;
									//strcat($$.str,"--");
									tee=create_NC();
									tee->type='S';
									tee->inc=SUB;
									tee->link=copy_NC($1.NCell);
									tee->link->list=create_NC();
									tee->link->list->type='C';
									tee->link->list->inc=1;
									$$.DTr=create_DT($1.NCell,tee);
									$$.NCell=$1.NCell;
									$$.inc=1+$1.inc;
								}
	;

argument_expression_list
	: assignment_expression		{ 	//$$.str=$1.str; 
									$$.NCell=$1.NCell;
									$$.DTL=$1.DTL;
									$$.inc=$1.inc;
								}
	| argument_expression_list ',' assignment_expression
								{
									//$$.str=(char*)malloc(40*sizeof(char));
									//sprintf($$.str,"%s,%s",$1.str,$3.str);
									$$.NCell=$1.NCell;
									while($1.NCell->list!=NULL)
										$1.NCell=$1.NCell->list;
									$1.NCell->list=$3.NCell;
									$$.DTL = $1.DTL; // to be changed if necessary :)
								}
	;

unary_expression
	: postfix_expression		{		//$$.str=$1.str;
									//$$.NCell=$1.NCell;
									$$.DTr=$1.DTr;
									$$.inc=$1.inc;
								}
	| INC_OP unary_expression	{
									//$$.str=(char*)malloc(40*sizeof(char));
									//sprintf($$.str,"++%s",$2.str);
									$$.NCell=create_NC();
									$$.NCell->type='S';
									$$.NCell->inc=ADD;
									$$.NCell->link=$2.NCell;
									$$.NCell->link->list=create_NC();
									$$.NCell->link->list->type='C';
									$$.NCell->link->list->inc=1;
									tee=copy_NC($$.NCell);
									$$.DTr=create_DT($2.NCell,tee);
									$$.inc=$2.inc+10;
								}
	| DEC_OP unary_expression	{		//$$.str=(char*)malloc(40*sizeof(char));
									//sprintf($$.str,"--%s",$2.str);
									$$.NCell=create_NC();
									$$.NCell->type='S';
									$$.NCell->inc=SUB;
									$$.NCell->link=$2.NCell;
									$$.NCell->link->list=create_NC();
									$$.NCell->link->list->type='C';
									$$.NCell->link->list->inc=1;
									tee=copy_NC($$.NCell);
									$$.DTr=create_DT($2.NCell,tee);
									$$.inc=$2.inc+10;
								}
	| unary_operator cast_expression
								{	//$$.str=(char*)malloc(40*sizeof(char));
									//sprintf($$.str,"%s%s",$1.str,$2.str);
									$$.NCell=create_NC();
									if($1.op==ADD) {
									$$.NCell->inc=$2.NCell->inc;
									$$.NCell->type='S';}
									else if($1.op==SUB) {
									$$.NCell->inc=-$2.NCell->inc;
									$$.NCell->type='S';}
									else if($1.op==NEG){
									$$.NCell->inc=NEG;
									$$.NCell->type='O';}
									else if($1.op==NOT){
									$$.NCell->inc=NOT;
									$$.NCell->type='O';}
									else {
									$$.NCell->type='T';
									$$.NCell->inc=IDK;}
									$$.NCell->link=$2.NCell;
									$$.DTr=NULL;
									$$.inc=$2.inc;
								}
	| SIZEOF unary_expression		{	$$.NCell=NULL;
							$$.DTr=NULL;
								$$.inc=0; }
	| SIZEOF '(' type_name ')'		{	$$.NCell=NULL;
							$$.DTr=NULL;
							$$.inc=0; }
	;

unary_operator
	: '&'	{strcpy($$.str,"&");$$.op=0;/*did not keep any operation for this*/}
	| '*'	{strcpy($$.str,"*");$$.op=MUL;}
	| '+'	{strcpy($$.str,"+");$$.op=ADD;}
	| '-'	{strcpy($$.str,"-");$$.op=SUB;}
	| '~'	{strcpy($$.str,"~");$$.op=NEG;}
	| '!'	{strcpy($$.str,"!");$$.op=NOT;}
	;

cast_expression
	: unary_expression		{		//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| '(' type_name ')' cast_expression
							{	//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"(int)%s",$4.str);
								/* no declarations for type_name and considering */
								/* present cases as integer itself */
								$$.NCell=$4.NCell;
								/* change data type? */
								$$.DTr=$4.DTr;
								$$.inc=$4.inc;
							}
	;

multiplicative_expression
	: cast_expression		{		//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| multiplicative_expression '*' cast_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s*%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,MUL);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| multiplicative_expression '/' cast_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s/%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,DIV);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| multiplicative_expression '%' cast_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s%%%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,REM);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

additive_expression
	: multiplicative_expression	{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| additive_expression '+' multiplicative_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s+%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,ADD);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| additive_expression '-' multiplicative_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s-%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,SUB);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

shift_expression
	: additive_expression	{		//$$.str=$1.str;
								//$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| shift_expression LEFT_OP additive_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s<<%s",$1.str,$3.str);
								$$.NCell=NULL;
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| shift_expression RIGHT_OP additive_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s>>%s",$1.str,$3.str);
								$$.NCell=NULL;
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

relational_expression
	: shift_expression		{		//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| relational_expression '<' shift_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s<%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,LTR);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| relational_expression '>' shift_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s>%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,GTR);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| relational_expression LE_OP shift_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s<=%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,LER);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| relational_expression GE_OP shift_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s>=%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,GER);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

equality_expression
	: relational_expression	{		//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| equality_expression EQ_OP relational_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s==%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,EQR);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	| equality_expression NE_OP relational_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s!=%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,NER);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

and_expression
	: equality_expression	{		//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| and_expression '&' equality_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s&%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,AND);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

exclusive_or_expression
	: and_expression		{		//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| exclusive_or_expression '^' and_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s^%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,XOR);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

inclusive_or_expression
	: exclusive_or_expression	{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| inclusive_or_expression '|' exclusive_or_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								// sprintf($$.str,"%s|%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,ORP);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

logical_and_expression
	: inclusive_or_expression	{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| logical_and_expression AND_OP inclusive_or_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s&&%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,ANDOP);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

logical_or_expression
	: logical_and_expression	{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| logical_or_expression OR_OP logical_and_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s||%s",$1.str,$3.str);
								$$.NCell=link_NC($1.NCell,$3.NCell,OROP);
								if($1.DTr==NULL)
								$$.DTr=$3.DTr;
								else $$.DTr=$1.DTr;
								$$.inc=$1.inc+$3.inc;
							}
	;

conditional_expression
	: logical_or_expression		{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	| logical_or_expression '?' expression ':' conditional_expression	{
								// $$.str=$1.str;
								/* states need to b added here itself */
								/* so total data construction need to be changed */
								/* $$.inc=$1.inc+$3.inc; check once */
							}
	;

assignment_expression
	: conditional_expression	{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								if($1.DTr!=NULL){
								$$.DTL=(DT_LIST *)malloc(sizeof(DT_LIST));
								$$.DTL->trans=$1.DTr;}
								else $$.DTL=NULL;
								$$.inc=$1.inc;
							}
	| unary_expression assignment_operator assignment_expression	{
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s%s%s",$1.str,$2.str,$3.str);
									tee=copy_NC($1.NCell);
								if($2.op!=EQU) {
								$$.NCell=link_NC($1.NCell,$3.NCell,$2.op);
								}
								else {$$.NCell=$3.NCell;}
								$$.DTL=(DT_LIST *)malloc(sizeof(DT_LIST));
								$$.DTL->trans=create_DT(tee,$$.NCell);
								free(tee);
								if($3.DTL!=NULL) {
									// $$.DTL->next=(DT_LIST *)malloc(sizeof(DT_LIST));
									$$.DTL->next=$3.DTL;
								}
								$$.inc=$3.inc;
							}
	;

assignment_operator
	: '='						{	strcpy($$.str,"=");$$.op=EQU;}
	| MUL_ASSIGN			{	strcpy($$.str,"*=");$$.op=MUL;}
	| DIV_ASSIGN			{	strcpy($$.str,"/=");$$.op=DIV;}
	| MOD_ASSIGN			{	strcpy($$.str,"%=");$$.op=REM;}
	| ADD_ASSIGN			{	strcpy($$.str,"+=");$$.op=ADD;}
	| SUB_ASSIGN			{	strcpy($$.str,"-=");$$.op=SUB;}
	| LEFT_ASSIGN			{	strcpy($$.str,"<<=");$$.op=ELF;}
	| RIGHT_ASSIGN			{	strcpy($$.str,">>=");$$.op=ERF;}
	| AND_ASSIGN			{	strcpy($$.str,"&=");$$.op=AND;}
	| XOR_ASSIGN			{	strcpy($$.str,"^=");$$.op=XOR;}
	| OR_ASSIGN				{	strcpy($$.str,"|=");$$.op=ORP;}
	;

expression
	: assignment_expression	{	//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTL=$1.DTL;
								$$.inc=$1.inc;
							}
	| expression ',' assignment_expression	{
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s,%s",$1.str,$3.str);
								$$.DTL=$1.DTL;
								if($1.DTL!=NULL){
								while($1.DTL->next!=NULL)
									$1.DTL=$1.DTL->next;
								if($3.DTL!=NULL){
								$1.DTL->next=(DT_LIST *)malloc(sizeof(DT_LIST));
								$1.DTL->next=$3.DTL;
								}}
								else if($3.DTL!=NULL) $$.DTL=$3.DTL;
								$$.NCell=$3.NCell;
								$$.inc=2*$1.inc+$3.inc;
							}
	;

constant_expression
	: conditional_expression	{
								//$$.str=$1.str;
								$$.NCell=$1.NCell;
								$$.DTr=$1.DTr;
								$$.inc=$1.inc;
							}
	;

declaration
	: declaration_specifiers ';'	{
								//$$.str=$1.str;
								strcat($$.str,";");
								$$.prev=-1;$$.next=-1;
							}
	| declaration_specifiers init_declarator_list ';' {
								//$$.str=(char*)malloc(40*sizeof(char));
								//sprintf($$.str,"%s %s;",$1.str,$2.str);
							if($2.DTL!=NULL){
								sprintf(c2f->states[state_count].state_id,"%s%d",temps,1000+state_count);
								c2f->numstates++;
								c2f->states[state_count].node_type=NORMAL;
								INfsmd(&c2f->states[prev_state],state_count,NULL,$2.DTL);
								$$.prev=prev_state;
								$$.next=state_count;
								prev_state=state_count;
								state_count++;
								}
							else{
								$$.prev=-1;
								$$.next=-1;
								}
								// printf("** Parser : declarations:= %s\n",$$.str);
								if($2.DTL==NULL) printf("no declarations listed\n");
								else printf("declarations\n");
							}
	;

declaration_specifiers
	: storage_class_specifier	{	$$.vart=0;strcpy($$.str,"\0"); }
	| storage_class_specifier declaration_specifiers	{	$$.vart=0;strcpy($$.str,"\0") }
	| type_specifier		{	vartype=$$.vart=$1.vart;
								strcpy($$.str,$1.str);
							}
	| type_specifier declaration_specifiers{$$.vart=$1.vart;
								sprintf($$.str,"%s %s",$1.str,$2.str);
							}
	| type_qualifier	{	$$.vart=0;strcpy($$.str,"\0"); }
	| type_qualifier declaration_specifiers	{	$$.vart=0;strcpy($$.str,"\0"); }
	;

init_declarator_list
	: init_declarator	{		//$$.str=$1.str;
								$$.DTL=$1.DTL;
							}
	| init_declarator_list ',' init_declarator	{
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s,%s",$1.str,$3.str);
								printf("~~~~~~~~~~~~~~ list : %s %s %s\n",$1.str,$3.str,$$.str);
							
								if($1.DTL==NULL) $$.DTL=$3.DTL;
								else {
									$$.DTL=$1.DTL;
									while($1.DTL->next!=NULL) $1.DTL=$1.DTL->next;
									$1.DTL->next=$3.DTL;
								}
							}
	;

init_declarator
	: declarator	{		$$.DTL=searchinsert($1.idnt,$1.lst,NULL,vartype);
						if($$.DTL==NULL) printf("** Parser : No data intialization in id: %s\n",$1.idnt);
						//$$.str=$1.str;
						printf("******* Parser : cool inserted %s\n", $1.idnt);
					}
	| declarator '=' initializer{
						$$.DTL=searchinsert($1.idnt,$1.lst,$3.lst,vartype);
						if($$.DTL==NULL) printf("** Parser : No data declaration in id: %s\n",$1.idnt);
						else printf("** Parser : data declared as id: %s\n",$1.idnt);
						//$$.str=(char*)malloc(40*sizeof(char));
						//sprintf($$.str,"%s=%s",$1.str,$3.str);
						printf("******* Parser : cool inserted %s\n", $1.idnt);
					}
	;

storage_class_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID				{ $$.vart = 0;strcpy($$.str,"void");}
	| CHAR				{ $$.vart = Char;strcpy($$.str,"char");}
	| SHORT				{ $$.vart = Int;strcpy($$.str,"short");}
	| INT				{ $$.vart = Int;strcpy($$.str,"int");}
	| LONG				{ $$.vart = Int;strcpy($$.str,"long");}
	| FLOAT				{ $$.vart = Float;strcpy($$.str,"float");}
	| DOUBLE			{ $$.vart = Float;strcpy($$.str,"float");}
	| SIGNED			{ $$.vart = 0;strcpy($$.str,"signed");}
	| UNSIGNED			{ $$.vart = 0;strcpy($$.str,"unsigned");}
	| struct_or_union_specifier{ $$.vart = 0;strcpy($$.str,"\0");}
	| enum_specifier		{ $$.vart = 0;strcpy($$.str,"\0");}
	| TYPE_NAME		{ $$.vart = 0;strcpy($$.str,"\0");}
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST
	| VOLATILE
	;

declarator
	: pointer direct_declarator	{
								$$.idnt=$2.idnt;
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s%s",$1.str,$2.str);
								LIST *temp;
								temp=$$.lst;
								while($1.cnt>1){
								temp=create_list();
								temp=temp->next;
								$1.cnt--;
								}
								temp=$2.lst;
							}
	| direct_declarator		{		$$.idnt=$1.idnt;
								//$$.str=(char*)malloc(100*sizeof(char));
								//strcpy($$.str,$1.str);
								$$.lst=$1.lst;
							}
	;

direct_declarator
	: IDENTIFIER			{		printf("** Parser : identifier found %s\n",$1);
								$$.idnt=$1;
								//$$.str=(char*)malloc(100*sizeof(char));
								//strcpy($$.str,$$.idnt);
								$$.lst=NULL;
							}
	| '(' declarator ')'		{	/*$$.str=NULL;*/$$.lst=NULL; }
	| direct_declarator '[' constant_expression ']' {
								$$.idnt=$1.idnt;
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s[%s]",$1.str,$3.str);
							if($1.lst==NULL){
								$$.lst=create_list();
								$$.lst->exprs=$3.NCell;
								}
							else{
								$$.lst=$1.lst;
								while($1.lst->next!=NULL)
									$1.lst=$1.lst->next;
								$1.lst->next=create_list(); 
								$1.lst->next->exprs=$3.NCell;
								}
								}
	| direct_declarator '[' ']'	{
								$$.idnt=$1.idnt;
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s[]",$1.str);
								$$.lst=$1.lst;
						if($$.lst==NULL) {
								$$.lst=create_list();
								$$.lst->exprs=create_NC();
								$$.lst->exprs->type='C';
								$$.lst->exprs->inc=10;	/* default array size in a dimension */
							}
						else{
								while($1.lst->next!=NULL)
									$1.lst=$1.lst->next;
								$1.lst->next=create_list();
								$1.lst->next->exprs=create_NC();
								$1.lst->next->exprs->type='C';
								$1.lst->next->exprs->inc=10;	/* default array size in a dimension */
							}
						}
	| direct_declarator '(' parameter_type_list ')'		{
											//$$.str=$1.str;
											$$.lst=NULL;
											tmp=&$3;
											while(tmp!=NULL){
											// dtlst=searchinsert(tmp->idnt,NULL,NULL,tmp->vart);
											input_count++;
											tmp->index=indexoftable(tmp->idnt);
											tmp=tmp->next;
											}
											tmp=&$3;
											printf("**function inputs : \n");
											while(tmp!=NULL) {
												printf("%s %d\n",tmp->idnt,tmp->index); 
												tmp=tmp->next;
											}
											tmp1=copy_lisT(&$3);
										}
	| direct_declarator '(' identifier_list ')'		{	/*$$.str=$1.str;*/$$.lst=NULL;printf("22 plese check exit in 945 line n comment it\n"); exit(1);	}
	| direct_declarator '(' ')'		{	/*$$.str=$1.str;*/$$.lst=NULL;/*printf("33\n");exit(1); */}
	;

pointer
	: '*'			{strcpy($$.str,"*");$$.cnt=1;}
	| '*' type_qualifier_list	{ strcpy($$.str,"\0");$$.cnt=0; }
	| '*' pointer	{sprintf($$.str,"*%s",$2.str);$$.cnt++;}
	| '*' type_qualifier_list pointer	{ strcpy($$.str,"\0");$$.cnt=0; }
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;


parameter_type_list
	: parameter_list	{$$=$1;}
	| parameter_list ',' ELLIPSIS	{$$=$1;}
	;

parameter_list
	: parameter_declaration		{ 	$$=$1; 
								// printf("check point : \n%s\t%s\n",$1.idnt,$$.idnt);
							}
	| parameter_list ',' parameter_declaration	
							{	 $$=$1; 
								// printf("**********************************************\n");
								// printf("%s\t%s\n",$1.idnt,$3.idnt);
								tmp=&$$;
								if(tmp->next!=NULL)
									while(tmp->next==NULL)
										tmp=tmp->next;
								tmp->next=&$3;
							}
	;

parameter_declaration
	: declaration_specifiers declarator	{
										$$.idnt=$2.idnt;
										$$.vart=$1.vart;
										$$.index=-5;
										$$.next=NULL;
							dtlst=searchinsert($2.idnt,$2.lst,NULL,$1.vart);
									}
	| declaration_specifiers abstract_declarator {$$.idnt=NULL;$$.vart=0; $$.index=-5;$$.next=NULL;
										printf("hello line no : 1002 (parameter_declaration : )\n");exit(1);
											}
	| declaration_specifiers				{$$.idnt=NULL;$$.vart=0; $$.index=-5;$$.next=NULL;
											}
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression	{	$$.lst=create_list();
								// $$.str=(char*)malloc(100*sizeof(char));
								//strcpy($$.str,$1.str);
								$$.lst->exprs=$1.NCell;
							}
	| '{' initializer_list '}'	{ 		$$.lst=$2.lst;
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"{%s}",$2.str);
							}
	| '{' initializer_list ',' '}'	{
								$$.lst=$2.lst;
								if($2.lst==NULL) {
									$$.lst=create_list();
									$$.lst->next=create_list();
								}
							else{
								temp_int=1;
								while($2.lst->next!=NULL) {
									$2.lst=$2.lst->next;
									temp_int++;
									}
								while(temp_int>0){
									$2.lst->next=create_list();
									$2.lst=$2.lst->next;
									temp_int--;
								}
								}
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"{%s,}",$2.str);
							}
	;

initializer_list
	: initializer				{	//$$.str=(char*)malloc(100*sizeof(char));
								//strcpy($$.str,$1.str);
								$$.lst=$1.lst;
							}
	| initializer_list ',' initializer	{
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s,%s",$1.str,$3.str);
								if($1.lst==NULL) {
									$$.lst=create_list();
									$$.lst->next=create_list();
								}
								else{
								$$.lst=$1.lst;
								while($1.lst->next!=NULL)
									$1.lst=$1.lst->next;
								$1.lst->next=$3.lst;
								}
							}
	;

statement
	: labeled_statement	{	$$.prev=-1;$$.next=-1;	}
	| compound_statement	{	$$.prev=$1.prev;
								$$.next=$1.next;
							}
	| expression_statement	{	
							if($1.NCell!=NULL || $1.DTL!=NULL){
								sprintf(c2f->states[state_count].state_id,"%s%d",temps,1000+state_count);
								c2f->states[state_count].node_type=NORMAL;
								c2f->numstates++;
								printf("** Parser : expression :: %s\n",string_DTr($1.DTL->trans));
								INfsmd(&c2f->states[prev_state],state_count,NULL,$1.DTL);
								$$.prev=prev_state;
								$$.next=state_count;
								prev_state=state_count;
								state_count++;
							}
							else{
								$$.prev=-1;
								$$.next=state_count;
								}
							}
	| selection_statement	{	$$.prev=$1.prev;
								$$.next=$1.next;
							}
	| iteration_statement	{	$$.prev=$1.prev;
								$$.next=$1.next;
							}
	| jump_statement	{	$$.prev=$1.prev;$$.next=$1.next;	}
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'				{	$$.prev=-1;
								$$.next=-1;
							}
	| '{' statement_list '}'{	$$.prev=$2.prev;
								$$.next=$2.next;
							}
	| '{' declaration_list '}'{	$$.prev=$2.prev;
								$$.next=$2.next;
							}
	| '{' declaration_list statement_list '}'	{
								if($2.prev==-1) $$.prev=$3.prev;
								else $$.prev=$2.prev;
								
								if($3.prev==-1) $$.next=$2.next;
								else $$.next=$3.next;
							}
	;

declaration_list
	: declaration			{	$$.prev=$1.prev;
								$$.next=$1.next;
							}
	| declaration_list declaration	{
								if($1.prev==-1) $$.prev=$2.prev;
								else $$.prev=$1.prev;
								
								if($2.prev==-1) $$.next=$1.next;
								else $$.next=$2.next;
							}
	;

statement_list
	: statement				{	$$.prev=$1.prev;
								$$.next=$1.next;
							}
	| statement_list statement{	
								if($1.prev==-1) $$.prev=$2.prev;
								else $$.prev=$1.prev;
								
								if($2.prev==-1) $$.next=$1.next;
								else $$.next=$2.next;
							}
	;

expression_statement
	: ';'				{ 			//$$.str=(char*)malloc(20*sizeof(char));
								//strcpy($$.str,";");
								$$.DTL=NULL;
								$$.prev=-1;
								$$.next=state_count;
								$$.NCell=NULL;
							}
	| expression ';'	{			
								//$$.str=(char*)malloc(100*sizeof(char));
								//sprintf($$.str,"%s;",$1.str);
								$$.prev=-1;
								$$.next=state_count;
// print_NC($1.NCell);
// printf("string: %s\n",string_NC($1.NCell));
								$$.NCell=$1.NCell;
								$$.DTL=$1.DTL;
							}
	;

selection_statement
	: IF '(' expression ')' statement	{
								if($5.prev!=-1){
								// printf("in IF : %s & %s\n",string_NC($3.NCell),string_NC(NNC($3.NCell)));
								split($5.prev,state_rcnt);
								INfsmd(&c2f->states[state_rcnt],$5.prev,$3.NCell,NULL);
								INfsmd(&c2f->states[state_rcnt],$5.next,NNC($3.NCell),NULL);
								$$.prev=state_rcnt;
								$$.next=$5.next;
								state_rcnt--;
								
								#ifdef DOTTY
								l2->start=state_rcnt+1;
								l2->start1=$5.prev;	// this stable
								l2->end=$5.next;
								l2->type=IFL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count++;
								#endif
								
								}
								else { $$.prev=$5.prev;$$.next=$5.next; }
							}
	| IF '(' expression ')' statement ELSE statement	{
								if($5.prev!=-1){
								split($5.prev,state_rcnt);
								INfsmd(&c2f->states[state_rcnt],$5.prev,$3.NCell,NULL);
								state_rcnt--;
								if($7.prev!=-1){
// printf("in IF ELSE : %s & %s\n",string_NC($3.NCell),string_NC(NNC($3.NCell)));
					 			// if($7.prev!=$5.next){ printf("error in if-else\n"); exit(1); }
								split($7.prev,$7.next); //state_rcnt); check this line
								INfsmd(&c2f->states[state_rcnt+1],$7.prev,NNC($3.NCell),NULL);
//								INfsmd(&c2f->states[state_rcnt],$7.next,NULL,NULL);
//								state_rcnt--;
								$$.prev=state_rcnt+1;//2;
								$$.next=$7.next;
								
								#ifdef DOTTY
								l2->start=state_rcnt+1;
								l2->start1=$5.prev;	// this stable
								l2->end=$7.next;
								l2->type=IFEL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								l2->start=state_rcnt+1;
								l2->start1=$7.prev;	// this stable
								l2->end=$7.next;
								l2->type=IFEL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif
								
								}
								else {
								INfsmd(&c2f->states[state_rcnt+1],$5.next,NNC($3.NCell),NULL);
								$$.prev=state_rcnt+1;
								$$.next=$5.next;
								
								#ifdef DOTTY
								l2->start=state_rcnt+1;
								l2->start1=$5.prev;	// this stable
								l2->end=$5.next;
								l2->type=IFL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count++;
								#endif
								
								}
								}
								else{
								if($7.prev!=-1){
								split($7.prev,state_rcnt);
								INfsmd(&c2f->states[state_rcnt],$7.prev,NNC($3.NCell),NULL);
								INfsmd(&c2f->states[state_rcnt],$7.next,$3.NCell,NULL);
								state_rcnt--;
								$$.prev=state_rcnt;
								
								
								#ifdef DOTTY
								l2->start=state_rcnt+1;
								l2->start1=$7.prev;	// this stable
								l2->end=$7.next;
								l2->type=IFL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif
								
								}
								else $$.prev=$7.prev;
								$$.next=$7.next;
								}
							}
	| SWITCH '(' expression ')' statement		{	$$.prev=-1;$$.next=-1;	}
	;

iteration_statement
	: WHILE '(' expression ')' statement {
								if($5.prev!=-1){
								split($5.prev,state_rcnt-1);
								split($5.next,state_rcnt);
								INfsmd(&c2f->states[state_rcnt],$5.prev,$3.NCell,NULL);
								INfsmd(&c2f->states[state_rcnt],$5.next,NNC($3.NCell),NULL);
								INfsmd(&c2f->states[state_rcnt-1],state_rcnt,NULL,NULL);
								$$.prev=state_rcnt-1;
								$$.next=$5.next;
								state_rcnt-=2;
								
								#ifdef DOTTY
								l2->start=state_rcnt+1;
								l2->start1=state_rcnt+2;
								l2->end=$5.next;
								l2->type=WHILEL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif
								
								}
								else {
									if($3.NCell!=NULL){
								intialize_state(state_count);
								INfsmd(&c2f->states[prev_state],state_count,NULL,NULL);
								intialize_state(state_count+1);
								INfsmd(&c2f->states[state_count],state_count+1,$3.NCell,NULL);
								intialize_state(state_count+2);
								INfsmd(&c2f->states[state_count+1],state_count,NULL,NULL);
								INfsmd(&c2f->states[state_count],state_count+2,NNC($3.NCell), NULL);
								$$.prev=prev_state;
								$$.next=state_count+2;
								prev_state=state_count+2;
								state_count+=3;

								#ifdef DOTTY
								l2->start=prev_state;// loop begin
								l2->start1=state_count-3;// loop start
								l2->end=state_count-1;	// loop end & not a stable pointer chances of changing
								l2->type=WHILEL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif

								}}
							}
	| DO statement WHILE '(' expression ')' ';'	{
								if($2.prev!=-1){
								split($2.prev,state_rcnt-1);
								split($2.next,state_rcnt);
// print_NC($5.NCell);
// printf("%s\n",string_NC($5.NCell));
								INfsmd(&c2f->states[state_rcnt],$2.prev,$5.NCell,NULL);
								INfsmd(&c2f->states[state_rcnt],$2.next,NNC($5.NCell),NULL);
								INfsmd(&c2f->states[state_rcnt-1],state_rcnt,NULL,NULL);
								$$.prev=state_rcnt-1;
								$$.next=$2.next;
								state_rcnt-=2;
								
								#ifdef DOTTY
								l2->start=state_rcnt+1;
								l2->start1=state_rcnt+2;
								l2->end=$2.next;
								l2->type=WHILEL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif
								
								}
								else {
									if($5.NCell!=NULL){
								intialize_state(state_count);
								INfsmd(&c2f->states[prev_state],state_count,NULL,NULL);
								intialize_state(state_count+1);
								INfsmd(&c2f->states[state_count],state_count+1,$5.NCell,NULL);
								intialize_state(state_count+2);
								INfsmd(&c2f->states[state_count+1],state_count,NULL,NULL);
								INfsmd(&c2f->states[state_count],state_count+2,NNC($5.NCell), NULL);
								$$.prev=prev_state;
								$$.next=state_count+2;
								prev_state=state_count+2;
								state_count+=3;

								#ifdef DOTTY
								l2->start=prev_state;// loop begin
								l2->start1=state_count-3;// loop start
								l2->end=state_count-1;	// loop end & not a stable pointer chances of changing
								l2->type=WHILEL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif

								}}
							}
	| FOR '(' expression_statement expression_statement ')' statement {
								if($6.prev!=-1){
								split($6.prev,state_rcnt-1);
//								addexpr($3.DTL,state_rcnt);
											// loop_begin
//								strcpy(comments[state_rcnt-1],$3.str);
//								strcat(comments[state_rcnt-1],$4.str);
								split($6.next,state_rcnt-2);
								sprintf(c2f->states[state_rcnt].state_id,"%s%d",temps,1000+state_rcnt);
								c2f->states[state_rcnt].node_type=NORMAL;
								c2f->states[state_rcnt].numtrans=0;
								INfsmd(&c2f->states[state_rcnt-1],state_rcnt,NULL,$3.DTL);
								INfsmd(&c2f->states[state_rcnt-2],state_rcnt,NULL,NULL);
								INfsmd(&c2f->states[state_rcnt],$6.prev,$4.NCell,NULL);
								INfsmd(&c2f->states[state_rcnt],$6.next,NNC($4.NCell),NULL);
											// loop_end
sprintf(comments[state_rcnt-1],"/* ");
dtlst=$3.DTL;
while(dtlst!=NULL){
strcat(comments[state_rcnt-1],string_DTr(dtlst->trans));
strcat(comments[state_rcnt-1],",");
dtlst=dtlst->next;
}
strcat(comments[state_rcnt-1],"; ");
string_NC($4.NCell,printer);
strcat(comments[state_rcnt-1],printer);
strcat(comments[state_rcnt-1],"; */");
							//	sprintf(comments[state_rcnt-1],"/* %s %s */",$3.str,$4.str);
								strcat(c2f->states[state_rcnt-1].state_id,"LB");
								strcpy(comments[state_rcnt],"2");
								$$.prev=state_rcnt-1;
								$$.next=$6.next;
								state_rcnt-=3;
								
								#ifdef DOTTY
								l2->start=state_rcnt+2;// loop begin
								l2->start1=state_rcnt+3;// loop start
								l2->end=$6.next;	// loop end & not a stable pointer chances of changing
								l2->type=FORL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif
								
								}
								else {
									if($4.NCell!=NULL){
								intialize_state(state_count);
								INfsmd(&c2f->states[prev_state],state_count,NULL,$3.DTL);
								intialize_state(state_count+1);
								INfsmd(&c2f->states[state_count],state_count+1,$4.NCell,NULL);
								intialize_state(state_count+2);
								INfsmd(&c2f->states[state_count+1],state_count,NULL,NULL);
								INfsmd(&c2f->states[state_count],state_count+2,NNC($4.NCell), NULL);
sprintf(comments[prev_state],"/* ");
dtlst=$3.DTL;
while(dtlst!=NULL){
strcat(comments[prev_state],string_DTr(dtlst->trans));
strcat(comments[prev_state],",");
dtlst=dtlst->next;
}
strcat(comments[prev_state],"; ");
string_NC($4.NCell,printer);
strcat(comments[prev_state],printer);
strcat(comments[prev_state],"; */");
strcpy(comments[state_count],"2");
								strcat(c2f->states[prev_state].state_id,"LB");
								$$.prev=prev_state;
								$$.next=state_count+2;
								prev_state=state_count+2;
								state_count+=3;

								#ifdef DOTTY
								l2->start=$$.prev;// loop begin
								l2->start1=state_count-3;// loop start
								l2->end=state_count-1;	// loop end & not a stable pointer chances of changing
								l2->type=FORL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif

								}}
							}
	| FOR '(' expression_statement expression_statement expression ')' statement	{
								if($7.prev!=-1){
								split($7.prev,state_rcnt-1);
											// loop_begin
								split($7.next,state_rcnt-2);
								sprintf(c2f->states[state_rcnt].state_id,"%s%d",temps,1000+state_rcnt);
								c2f->states[state_rcnt].node_type=NORMAL;
								c2f->states[state_rcnt].numtrans=0;
								INfsmd(&c2f->states[state_rcnt-1],state_rcnt,NULL,$3.DTL);
								INfsmd(&c2f->states[state_rcnt-2],state_rcnt,NULL,$5.DTL);
								INfsmd(&c2f->states[state_rcnt],$7.prev,$4.NCell,NULL);
								INfsmd(&c2f->states[state_rcnt],$7.next,NNC($4.NCell),NULL);
											// loop_end

sprintf(comments[state_rcnt-1],"/* ");
dtlst=$3.DTL;
while(dtlst!=NULL){
strcat(comments[state_rcnt-1],string_DTr(dtlst->trans));
strcat(comments[state_rcnt-1],",");
dtlst=dtlst->next;
}
strcat(comments[state_rcnt-1],"; ");
string_NC($4.NCell,printer);
strcat(comments[state_rcnt-1],printer);
strcat(comments[state_rcnt-1],"; ");
dtlst=$5.DTL;
while(dtlst!=NULL){
strcat(comments[state_rcnt-1],string_DTr(dtlst->trans));
strcat(comments[state_rcnt-1],",");
dtlst=dtlst->next;
}
strcat(comments[state_rcnt-1]," */");
								// sprintf(comments[state_rcnt-1],"/* %s %s %s */",$3.str,$4.str,$5.str);
								strcat(c2f->states[state_rcnt-1].state_id,"LB");
								strcpy(comments[state_rcnt],"2");
								$$.prev=state_rcnt-1;
								$$.next=$7.next;
								state_rcnt-=3;
								
								#ifdef DOTTY
								l2->start=state_rcnt+2;
								l2->start1=state_rcnt+3;
								l2->end=$7.next;
								l2->type=FORL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif

								
								}
								else {
									if($4.NCell!=NULL){
								intialize_state(state_count);
								INfsmd(&c2f->states[prev_state],state_count,NULL,$3.DTL);
								intialize_state(state_count+1);
								INfsmd(&c2f->states[state_count],state_count+1,$4.NCell,NULL);
								intialize_state(state_count+2);
								INfsmd(&c2f->states[state_count+1],state_count,NULL,$5.DTL);
								INfsmd(&c2f->states[state_count],state_count+2,NNC($4.NCell), NULL);
sprintf(comments[prev_state],"/* ");
dtlst=$3.DTL;
while(dtlst!=NULL){
strcat(comments[prev_state],string_DTr(dtlst->trans));
strcat(comments[prev_state],",");
dtlst=dtlst->next;
}
strcat(comments[prev_state],"; ");
string_NC($4.NCell,printer);
strcat(comments[prev_state],printer);
dtlst=$5.DTL;
while(dtlst!=NULL){
strcat(comments[state_rcnt-1],string_DTr(dtlst->trans));
strcat(comments[state_rcnt-1],",");
dtlst=dtlst->next;
}
strcat(comments[prev_state],"; */");
strcpy(comments[state_count],"2");
								strcat(c2f->states[prev_state].state_id,"LB");
								$$.prev=prev_state;
								$$.next=state_count+2;
								prev_state=state_count+2;
								state_count+=3;

								#ifdef DOTTY
								l2->start=prev_state;// loop begin
								l2->start1=state_count-3;// loop start
								l2->end=state_count-1;	// loop end & not a stable pointer chances of changing
								l2->type=FORL;
								l2->next=(loopi *)malloc(sizeof(loopi));
								l2=l2->next;
								loop_count+=1;
								#endif

								}
							}
							}
	;

jump_statement
	: GOTO IDENTIFIER ';'	{ $$.next=state_count;$$.prev=-1; }
	| CONTINUE ';'		{ $$.next=state_count;$$.prev=-1; }
	| BREAK ';'			{ sprintf(c2f->states[state_count].state_id,"%s%d",temps,1000+state_count);
								c2f->states[state_count].node_type=NORMAL;
								c2f->numstates++;
								printf("** Parser : expression :: BREAK\n");
								dtlst=(DT_LIST*)malloc(sizeof(DT_LIST));
								dtlst->trans=(DATA_TRANS*)malloc(sizeof(DATA_TRANS));
								transdata=dtlst->trans;
								transdata->lhs=indexoftable("BREAK");
								transdata->rhs=create_NC();
								transdata->rhs->type='C';
								transdata->rhs->inc=1;
								INfsmd(&c2f->states[prev_state],state_count,NULL,dtlst);
								$$.prev=prev_state;
								$$.next=state_count;
								prev_state=state_count;
								state_count++;
						}
	| RETURN ';'			{ $$.next=state_count;$$.prev=-1; }
	| RETURN expression ';'	{ 
							$$.next=state_count;
							$$.prev=-1;
							rtrn1->exprs=$2.NCell;
							rtrn1->next=(LIST*)malloc(sizeof(LIST));
							rtrn1=rtrn1->next;
							output_count++;
						}
	;

translation_unit
	: external_declaration			{
							printf("parsed\n");
							c2f->states[state_count-1].node_type=END;
							print_out(c2f,data);
							#ifdef DOTTY
							printf("\n\n\nDOTTY :\n");
							print_dotty(data);
							#endif
							printf("done\n"); 
}
	| translation_unit external_declaration	{
							printf("parsed with more than 1 function\n");
							print_out(c2f,data);
							printf("done\n");
}
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	| declarator declaration_list compound_statement
	| declarator compound_statement
	;

%%
#include <stdio.h>
#include<stdlib.h>
#include<string.h>
#include "header.h"

void yyerror(char const *s) {fprintf(stderr, "%s in line number %s\n", s, line_count(0));}

int main(){
	temps=(char *)malloc(sizeof(char)*40);
	#ifdef DOTTY
	l1=(loopi *)malloc(sizeof(loopi));
	l2=l1;
	rtrn=(LIST *)malloc(sizeof(LIST));
	rtrn1=rtrn;
	#endif
//	lineno=0;
	data=(char*)malloc(sizeof(char)*40);
	printer=(char*)malloc(sizeof(char)*40);
	print_count=1000;
//	scanf("%s",data);
//	scanf("%s",temps);
//	data+=2;
	strcpy(data,"newFSMD");
	strcpy(temps,"qq");
	printf("FSMD name: %s\n",temps);
	c2f=newFSMD();
	strcpy(c2f->name,data);
	c2f->numstates=1;
	sprintf(c2f->states[0].state_id,"%s1000",temps);
	c2f->states[0].node_type=START;
	errP=(int*)malloc(sizeof(int));
	current_table=newSymTab(NULL);
	dtlst=searchinsert("BREAK",NULL,NULL,Int);
//	dtlst=searchinsert("END",NULL,NULL,Int);
	dtlst=searchinsert("LOOP_END",NULL,NULL,Int);
	printf("starting yyparse : \n");
	int i=0;
	for(i=0;i<MAXSTATES;i++) strcpy(comments[i],"\0");


	sprintf(c2f->states[state_count].state_id,"%s%d",temps,1000+state_count);
	c2f->numstates++;
	c2f->states[state_count].node_type=NORMAL;
	INfsmd(&c2f->states[prev_state],state_count,NULL,NULL);
	prev_state=state_count;
	state_count++;
	return yyparse();
}


// functions :


/******************************************************************************************/

/*  This function is used to create a term a simple normalized cell               */
/*  It takes no input and returns the pointer */
/*  to the default normalized binary tree                                                         */

/******************************************************************************************/

// default create NC cell
NC* create_NC(){
	NC *T;
	T=(NC *)malloc(sizeof(NC));
	T->link=NULL;
	T->list=NULL;
	T->inc=0;
	T->type='V';
	return T;
}


void nameit(char *f,char *q){
strcpy(data,f);
strcpy(temps,q);
strcpy(c2f->name,data);
sprintf(c2f->states[0].state_id,"%s1000",temps);
printf("%s\t%s\n",c2f->name,c2f->states[0].state_id);
}


/******************************************************************************************/

/*  This function is used to create a term for a particular normalized term               */
/*  It takes the variable string as input and returns the pointer */
/*  to the normalized binary tree                                                         */

/******************************************************************************************/


// this will create NC cell for given variable
NC* create_term(char *varP){
	NC *T,*P;
	int i=indexoftable(varP);  //get the index of the symbol
	if( i >= 0 )
	{
		if(current_table->bucket[i].data_type != Funt){
		T=(NC *)malloc(sizeof(NC));
		P=(NC*) malloc(sizeof(NC));
		T->link=P;
		P->list=NULL;
		T->list=NULL;
		P->link=NULL;
		P->inc=i;
		P->type='V';
		T->type='T';
		T->inc=getvalue(i);
		return T;
		}
		else {
		T=create_NC();
		T->type = 'U';
		T->inc = indexoftable(varP);
		printf("***** function call found : function name : %s\n",varP);
		return T;
		}
	}
	else if(i==-2){
		printf("***** temporary variable insertion : %s\n",varP);
		dtlst=searchinsert(varP,NULL,NULL,Funt);
		T=create_NC();
		T->type = 'U';
		T->inc = indexoftable(varP);
		return T;
	}
	else 
		return NULL;
}


/******************************************************************************************/

/*  This function is used to to get the index of a variable from the symbol table               */
/*  It takes the variable string as input and returns the index */
/*  from symbol table                                                         */

/******************************************************************************************/

// index from hash table
int indexoftable(char *str){
int i=0;
symtab *table;table=current_table;
while(i<table->count){
if(strcmp(str,table->bucket[i].symP)==0)
return i;
i++;
}
return NOT_DEF;
}



/******************************************************************************************/

/*  This function is used to get the value of a variable from symbol table               */
/*  It takes the symbolic constant (index) as input and returns the integer value */
/*  from the symbol table                                                          */

/******************************************************************************************/


// getvalue by index
int getvalue(int i){
int j,k;j=i/1000;k=i%1000;
if(j==0 && current_table->bucket[k].dim==0)
return current_table->bucket[i%1000].val[i/1000];
else if(current_table->bucket[k].dim!=0) return IDK;		// check the intialization
else return current_table->bucket[i%1000].val[i/1000];
}




/******************************************************************************************/

/*  This function is used to transform a normalized binary tree to its opposite               */
/*  It takes the pointer to the normalized binary tree and returns another pointer */
/*  to the normalized binary tree of opposite kind                                                 */

/******************************************************************************************/


// negation of expression
NC *NNC(NC *in){
NC *temp;
temp=create_NC();
temp->type='O';
temp->inc=NOT;
temp->link=in;
return temp;
}


/******************************************************************************************/

/*  This function is used to create a new symbol table                */
/*  It takes no input and returns the pointer */
/*  to the symbol table                                                         */

/******************************************************************************************/

//	function to create a new symbol table
symtab *newSymTab(symtab *uP)
{
	symtab *table=(symtab*)malloc(sizeof(symtab));
	table->upTab = uP;
	table->downTab = NULL;
	table->count=0;
	int i;
	for(i=0;i<BUCKET_COUNT;i++)
	{
		//initialising all the pointers to NULL
		table->bucket[i].symP=NULL;
		table->bucket[i].val=NULL;
	}
	if(uP!=NULL)
	{
		uP->downTab = table;
	}
	return table;
}


/******************************************************************************************/

/*  This function is used to insert a variable in symbol table               */
/*  It takes the string variable and intialization list as input and returns the pointer */
/*  to the Data transition                                                         */

/******************************************************************************************/

// search and insert the variable & retrieve DATA_TRANS list
DT_LIST *searchinsert(char *varP,LIST *arry,LIST *intil,int type){
int i=0,j=1,k=0,i1;int listenter=0;
DT_LIST *lst,*lst1;
lst1=(DT_LIST *)malloc(sizeof(DT_LIST));
lst=lst1;
symtab *temp;temp=current_table;
while(temp->bucket[i].symP!=NULL){
if(strcmp(temp->bucket[i].symP,varP)==0){
printf("** SearchInsert : variable already intiallized \n");
printf("** SearchInsert : id = %s at position %d\n",varP,i);
exit(1);
// return NULL;
}
i++;
}
	temp->bucket[i].symP=(char *)malloc(sizeof(char)*strlen(varP));
	strcpy(temp->bucket[i].symP,varP);
	temp->bucket[i].data_type=type;
LIST *temp1,*temp2;
temp2=intil;
temp1=arry;i1=0;
temp->bucket[i].ar=(int*)malloc(sizeof(int)*10);
temp->bucket[i].ar[0]=1;int xx;
while(temp1!=NULL){
printf("~~~~~~~~~~~~~~~~~~~~ array found\n");
	if(temp1->exprs!=NULL){
	  xx=value_NC(temp1->exprs);
	  if(xx!=IDK) temp->bucket[i].ar[i1]=xx;
	  else temp->bucket[i].ar[i1]=10;
	}
	else temp->bucket[i].ar[i1]=1;
j*=temp->bucket[i].ar[i1];
temp1=temp1->next;
i1++;
}
	temp->bucket[i].dim=i1;
	temp->bucket[i].val=(int *)malloc(sizeof(int)*j);
k=0;j=1;
while(temp2!=NULL){
listenter=1;
if(temp2->exprs!=NULL) {
	temp->bucket[i].val[k]=value_NC(temp2->exprs);
	if(lst1==NULL) lst1=(DT_LIST *)malloc(sizeof(DT_LIST));
	lst1->trans=(DATA_TRANS *)malloc(sizeof(DATA_TRANS));
	lst1->trans->lhs=i+k*1000;
	lst1->trans->rhs=copy_NC(temp2->exprs);
}
else {
temp->bucket[i].val[k]=IDK;
if(lst1==NULL) lst1=(DT_LIST *)malloc(sizeof(DT_LIST));
// lst1->trans=(DATA_TRANS *)malloc(sizeof(DATA_TRANS));
// lst1->trans->lhs=k*1000+i;
// lst1->trans->rhs=NULL;
lst1->trans=NULL;
j=-2;
}
temp2=temp2->next;
if(temp2!=NULL) 	lst1->next=(DT_LIST *)malloc(sizeof(DT_LIST));
lst1=lst1->next;
k++;
}
if(j==-2) temp->bucket[i].defined=RE_DEF;
else temp->bucket[i].defined=DEF;
temp->count++;
printf("** SearchInsert : inserted : %s\tat position %d\n",varP,i);
if(listenter==1) return lst;
else return NULL;
}



/******************************************************************************************/

/*  This function is used to create a new FSMD data structure for a function               */
/*  It takes no input and returns the pointer                                                      */
/*  to the FDMD data structure                                                         */

/******************************************************************************************/


// create a new FSMD data structure and retrurn a pointer
FSMD *newFSMD(){
// printf("sizeof fsmd : %d\n",(int)sizeof(FSMD));
FSMD *temp1;
temp1=(FSMD *)malloc(sizeof(FSMD));
int i=0;
for(i=0;i<MAXSTATES;i++){
/* intialize all the node types as not defined */
temp1->states[i].node_type=UNDEF;
temp1->states[i].translist=NULL;
temp1->states[i].numtrans=0;
}
return temp1;
}



/******************************************************************************************/

/*  This function is used to add a new transition in  fsmd state             */
/*  It takes prev node and next node id along with normalised condition cell */
/*  and data transition list to be added as input and returns nothing */

/******************************************************************************************/

// inserting transition state in FSMD data structure
void INfsmd(NODE_ST *prev,int nxt,NC *condn,DT_LIST *list){
/* commented lines are for further modifications, not necessary now */
printf("** INfsmd : started\n");
int i=0;
DT_LIST *modf;
modf=list;
TRANSITION_ST *trans1;
trans1=create_TST();
trans1->condition=condn;
while(list!=NULL){
if(list->trans!=NULL){
trans1->action[i].lhs=list->trans->lhs;
trans1->action[i].flag=list->trans->flag;
trans1->action[i].rhs=copy_NC(list->trans->rhs);
i++;
}
list=list->next;
}
trans1->datatrans_cnt=i;
trans1->next=NULL;
trans1->outtrans=nxt;
if(prev->translist==NULL){
prev->translist=trans1;
prev->numtrans++;
}
else{
TRANSITION_ST *temp,*temp1;
temp=prev->translist;temp1=temp;
while(temp->next!=NULL) temp=temp->next;
temp->next=trans1;
prev->numtrans++;
}
char *str1=(char *)malloc(sizeof(char)*100);
string_NC(condn,str1);
printf("** INfsmd : state transition added %s\n",str1);
}


/******************************************************************************************/

/*  This function is used to link two data transition lists one after the other             */
/*  It takes two data transitions lists to be linked as input  */
/*  and returns a pointer to the resulting data transition list */

/******************************************************************************************/


// link two DATA TRANSITION lists
DT_LIST *link_DTLIST(DT_LIST *list1,DT_LIST *list2){
DT_LIST *temp,*temp1;
temp1=copy_DTLIST(list1);
temp=temp1;
if(temp1==NULL) return list2;
while(temp1->next!=NULL)
temp1=temp1->next;
temp1->next=copy_DTLIST(list2);
return temp;
}



/******************************************************************************************/

/*  This function is used to link two two normalised expressions with a new operator             */
/*  It takes two data normalised trees to be linked and operator as input  */
/*  and returns a pointer to the resulting normalised tree */

/******************************************************************************************/



// links two normalized trees as per the operator been used
NC* link_NC(NC *expr1,NC * expr2,int op){
NC *temp,*temp1;temp1=expr1;
if(temp1->type==op){
temp1=temp1->link;
while(temp1!=NULL)
	temp1=temp1->list;
temp1=expr2;
printf("~~~~~~~in link_NC:\n && direct maping output:\n");
// print_NC(expr1);
return expr1;
}
else {
temp=create_NC();
temp->link=expr1;
while(temp1->list!=NULL) temp1=temp1->list;
temp1->list=expr2;
if(op>90) temp->type='S';
else if(op>80) temp->type='R';
else temp->type='O';
temp->inc=op;
return temp;
}
}



/******************************************************************************************/

/*  This function is used to intialize a new DATA transition list             */
/*  It takes no input and returns the pointer to a new data transition list intialized */

/******************************************************************************************/

// creates a new DATA_TRANSITION list : DT_LIST
LIST *create_list(){
LIST *temp=(LIST *)malloc(sizeof(LIST));
temp->exprs=NULL;
temp->next=NULL;
return temp;
}

/******************************************************************************************/

/*  This function is used to intialize a new DATA transition stae             */
/*  It takes no input and returns the pointer to a new data transition state intialized */

/******************************************************************************************/


// create a new TRANSITIO_ST data structure and return a pointer 
TRANSITION_ST *create_TST(){
TRANSITION_ST *trans0;
// printf("error?\n");
trans0=(TRANSITION_ST *)malloc(sizeof(TRANSITION_ST));
		// here barcode.c showing error at 1755 line code
/* intialize to null */
// printf("NO!\n");
trans0->next=NULL;
trans0->datatrans_cnt=0;
trans0->condition=NULL;
return trans0;
}


/******************************************************************************************/

/*  This function is used to create a new data transition               */
/*  It two normalized trees as input and returns the pointer                       */
/*  to the newly created data transition                            */
/*  input: one for the left hand side variable and other for right side expression */

/******************************************************************************************/

// create a new data transition
DATA_TRANS* create_DT(NC *temp,NC *expr1){

	if(check_NC(temp) < 0){
		printf("variable used before declaration in line number %s\n",line_count(0));
		exit(1);
	}

DATA_TRANS *x;
NC *tp1;
int ll,i;
x=(DATA_TRANS *)malloc(sizeof(DATA_TRANS));
//x->rhs=copy_NC(expr1);
x->rhs=expr1;
// printf("create_DT : %c %c\n",temp->type,temp->link->type);
x->flag = FALSE;

if(temp->link->type=='V') {
	x->lhs = temp->link->inc;
}
else{
     	tp1=temp->link->link;
	ll=temp->link->inc;
i=current_table->bucket[ll].dim;
while(tp1!=NULL){
tp1=tp1->list;
i--;
}
if(i!=0){
printf("wrong entry in array dimension in line number %s\n",line_count(0));
printf("given dimension : %d, original dimension : %d\n",current_table->bucket[ll].dim-i,current_table->bucket[ll].dim);
exit(1);
}
tp1=temp->link;
	if((ll=get_index(tp1))!=-1)
	  x->lhs=ll;
	else {
	x->lhs_NC=copy_NC(temp);
	x->flag=TRUE;
char *str1=(char *)malloc(sizeof(char)*100);
string_NC(x->lhs_NC,str1);
	printf("!!!!!!!!!! DT created with array type lhs : %s %d %d %d\n",str1,sizeof(x->lhs),sizeof(x->lhs_NC),sizeof(NC));
	}
}
return x;
}



/******************************************************************************************/

/*  This function is used to to get the index of a variable from the symbol table               */
/*  It takes the normalized tree as input and returns the index */
/*  from symbol table : used for array variables                                 */

/******************************************************************************************/

// get index of variable represented in normalized tree form
int get_index(NC *temp){
 if( temp->type=='V' || temp->type=='v') return temp->inc;
else if(temp->type=='A' || temp->type=='a') {
  int i=0,k=1;i=temp->inc;
  k=array_index(temp->link,i);
if(k!=-1)
  return i+k*1000;
else {
return -1;
}
}
else {
printf("error in get_index NC type : %c\n",temp->type);
exit(1);
return IDK;
}
}


/******************************************************************************************/

/*  This function is used to to get the index of a array from the symbol table               */
/*  It takes the normalized tree and index of array pointer as input and returns the original index of variable */
/*  from symbol table : used for array variables                                  */

/******************************************************************************************/


// get array index of of variable represented in normalized form
int array_index(NC *NCell,int i){
  int in=0,j=1,jj=0,k=1;NC *temp1;
  temp1=NCell;
while(temp1!=NULL){
if(temp1->type == 'C')
  k=temp1->inc;
else k = -1;
  if(k==-1) {
	in = -1;
	break;
	}
  jj=j;
  while(jj<current_table->bucket[i].dim){
    k*=current_table->bucket[i].ar[jj];
    jj++;
  }
  in+=k;
  temp1=temp1->list;
  j++;
}
// if(in == -1) exit(1);
  return in;
}


// value of constant on basis of type_specifier.
int fvalue(char *temp,int op){
if(op==Int)	return atoi(temp);
else if(op==Float)	return atof(temp);
else if(op==Stor){
int i=0;
while(temp!='\0'){
i*=10;i+=(int)*temp;			// check
temp++;
}
return i;
}
else return 0;
}



/******************************************************************************************/

/*  This function is used to modify fsmd state transition lists               */
/*  It takes PREV and NEW state ids as input and returns nothing */
/*  replaces PREV by NEW in all transition lists so far                   */

/******************************************************************************************/



// assign a new state as next state to a list of transitions 
void split(int prev,int new){
FSMD *temp;temp=c2f;

if(temp->states[new].node_type!=NORMAL){
sprintf(temp->states[new].state_id,"%s%d",temps,1000+new);
temp->states[new].node_type=NORMAL;
temp->states[new].numtrans=0;
}

int i=0;
TRANSITION_ST *temp2;
while(i<temp->numstates){
temp2=temp->states[i].translist;
while(temp2!=NULL){
if(temp2->outtrans==prev) { temp2->outtrans=new;
//printf("in Split : changed at %d from %d to %d\n",i,prev,new);
}
temp2=temp2->next;
}
i++;
}
i=MAXSTATES-1;
while(i>state_rcnt){
if(i!=new){
temp2=temp->states[i].translist;
while(temp2!=NULL){
if(temp2->outtrans==prev) {
temp2->outtrans=new;
//printf("in Split : changed at %d from %d to %d\n",i,prev,new);
}
temp2=temp2->next;
}}
i--;
}}


/******************************************************************************************/

/*  This function is used to modify fsmd state transition lists               */
/*  It takes data transition lists and next state id as input and returns nothing */
/*  adds data transitions to the current state which is working on                  */

/******************************************************************************************/


// add few expressions to a state
void addexpr(DT_LIST *dtl,int out){
FSMD *temp;temp=c2f;
DT_LIST *temp3;
int i=0,j;
TRANSITION_ST *temp2;
while(i<temp->numstates){
temp3=dtl;
temp2=temp->states[i].translist;
while(temp2!=NULL){
if(temp2->outtrans==out){
while(temp3!=NULL){
j=temp2->datatrans_cnt;temp2->datatrans_cnt++;
temp2->action[j].lhs=temp3->trans->lhs;
temp2->action[j].flag=temp3->trans->flag;
/* if(sizeof(temp3->trans->lhs)==sizeof(int))
	temp2->action[j].lhs=temp3->trans->lhs;
else {
temp2->action[j].lhs_NC.list=temp3->trans->lhs_NC.list;
temp2->action[j].lhs_NC.type=temp3->trans->lhs_NC.type;
temp2->action[j].lhs_NC.inc=temp3->trans->lhs_NC.inc;
temp2->action[j].lhs_NC.link=temp3->trans->lhs_NC.link;
//temp2->action[j].lhs_NC=copy_NC(temp3->trans->lhs_NC);
printf("&&&&&&&&&&&&&&&&&&&&&&&&&& getting copied %s\n",string_NC(&temp2->action[j].lhs_NC));
}*/
temp2->action[j].rhs=temp3->trans->rhs;
temp3=temp3->next;
}
}
temp2=temp2->next;
}
i++;
}
i=MAXSTATES-1;
while(i>state_rcnt){
if(i!=out){
temp3=dtl;
temp2=temp->states[i].translist;
while(temp2!=NULL){
if(temp2->outtrans==out){
while(temp3!=NULL){
j=temp2->datatrans_cnt;temp2->datatrans_cnt++;
temp2->action[j].lhs=temp3->trans->lhs;
temp2->action[j].flag=temp3->trans->flag;
/* if(sizeof(temp3->trans->lhs)==sizeof(int))
	temp2->action[j].lhs=temp3->trans->lhs;
else {
temp2->action[j].lhs_NC.list=temp3->trans->lhs_NC.list;
temp2->action[j].lhs_NC.type=temp3->trans->lhs_NC.type;
temp2->action[j].lhs_NC.inc=temp3->trans->lhs_NC.inc;
temp2->action[j].lhs_NC.link=temp3->trans->lhs_NC.link;
//temp2->action[j].lhs_NC=copy_NC(temp3->trans->lhs_NC);
printf("&&&&&&&&&&&&&&&&&&&&&&& getting copied %s\n",string_NC(&temp2->action[j].lhs_NC));
}*/
temp2->action[j].rhs=temp3->trans->rhs;
// free(temp3->trans->rhs);		// free
temp3=temp3->next;
}
}
temp2=temp2->next;
}
}
i--;
}
}


/******************************************************************************************/

/*  This function is used to output normalized tree in an unsorted way.               */
/*  It takes normalized treee as input and output the string form to console */

/******************************************************************************************/


// to print a normalized tree in unsorted form
void print_NC(NC *NCell){
NC *temp;// char *str;
temp=NCell;
while(temp!=NULL){
printf("<%d,%c>\t",temp->inc,temp->type);
if(temp->link!=NULL)
	print_NC(temp->list);
printf("\n");
temp=temp->link;
}
}


/******************************************************************************************/

/*  This function is used to calculate the value in the normalized tree               */
/*  It takes normalized tree as input and returns the integer value of it */

/******************************************************************************************/


// to get the value of normalized tree
int value_NC(NC *temp){
if(temp!=NULL){
NC *temp1;
if(temp->type=='S'){
if(temp->inc==DIV)	return value_NC(temp->link)/value_NC(temp->link->list);
else if(temp->inc==MUL){
temp1=temp->link->list;int i=value_NC(temp->link);
while(temp!=NULL){
i*=value_NC(temp1);
temp1=temp1->list;
}
return i;
}
else if(temp->inc==ADD){
NC *temp1;temp1=temp->link->list;int i=value_NC(temp->link);
while(temp!=NULL){
i+=value_NC(temp1);
temp1=temp1->list;
}
return i;
}
else if(temp->inc==SUB){
NC *temp1;temp1=temp->link->list;int i=value_NC(temp->link);
while(temp!=NULL){
i-=value_NC(temp1);
temp1=temp1->list;
}
return i;
}
else if(temp->inc==REM) return value_NC(temp->link)%value_NC(temp->link->list);
else if(temp->inc==INC || temp->inc==INCP || temp->inc==DEC || temp->inc==DECP) return value_NC(temp->link);
else return ERP;
}
else if(temp->type=='T'){
if(temp->link->type=='V'){
return getvalue(temp->link->inc);
}
else if(temp->link->type=='A'){
  temp1=temp->link->link;
  i=0;int index=temp->link->inc,j=1,jj=0,k=1;
  while(temp1!=NULL){
  k=value_NC(temp1);jj=j;
  while(jj<current_table->bucket[index].dim){
    k*=current_table->bucket[index].ar[jj];
    jj++;
  }
  i+=k;
  temp1=temp1->list;
  j++;
}
  return getvalue(i);
}
else return ERP;
}
else if(temp->type=='R'){
if(temp->inc==LTR) return value_NC(temp->link)<value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==GTR) return value_NC(temp->link)>value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==LER) return value_NC(temp->link)<=value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==GER) return value_NC(temp->link)>=value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==EQR) return value_NC(temp->link)==value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==NER) return value_NC(temp->link)!=value_NC(temp->link->list) ? TRUES:FALSES;
else return IDK;
}
else if(temp->type=='C') return temp->inc;
else if(temp->type=='O'){
if (temp->inc==NEG)		return ~value_NC(temp->link) ? TRUES:FALSES;
else if(temp->inc==ANDOP || temp->inc==AND)	return value_NC(temp->link) && value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==OROP || temp->inc==ORP)	return value_NC(temp->link) || value_NC(temp->link->list) ? TRUES:FALSES;
else if(temp->inc==NOT)	return !value_NC(temp->link) ? TRUES:FALSES;
else if(temp->inc==XOR)	return value_NC(temp->link)^value_NC(temp->link->list) ? TRUES:FALSES;
else return IDK;
}
else return IDK;
}
return 0;
}


/******************************************************************************************/

/*  This function is used to copy a normalized expression                */
/*  It takes original normalized tree as input and returns the pointer */
/*  to newly intiated and copied data from original normalized tree                   */

/******************************************************************************************/



// copy a normalized tree into another
NC* copy_NC(NC *org){
NC *dest;
if(org!=NULL){
dest=(NC *)malloc(sizeof(NC));
dest->type=org->type;
dest->inc=org->inc;
dest->link=copy_NC(org->link);
dest->list=copy_NC(org->list);
}
else dest=NULL;
return dest;
}


/******************************************************************************************/

/*  This function is used to copy a normalized expression list               */
/*  It takes original normalized tree list as input and returns the pointer */
/*  to newly intiated and copied data from original normalized tree list                   */

/******************************************************************************************/

// copy a normalized tree list
LIST *copy_LIST(LIST *org){
if(org!=NULL){
LIST *dest;
dest=(LIST *)malloc(sizeof(LIST));
dest->exprs=copy_NC(org->exprs);
dest->next=copy_LIST(org->next);
return dest;
}
else return NULL;
}


/******************************************************************************************/

/*  This function is used to copy a data transition                */
/*  It takes original data transition expression as input and returns the pointer */
/*  to newly intiated and copied data from original data transition expression                   */

/******************************************************************************************/

// copy a data transition expression to another
DATA_TRANS *copy_DTr(DATA_TRANS *org){
if(org!=NULL){
DATA_TRANS *temp;
temp=(DATA_TRANS *)malloc(sizeof(DATA_TRANS));
temp->lhs=org->lhs;
temp->flag=org->flag;
/* if(sizeof(org->lhs)==sizeof(int))
	temp->lhs=org->lhs;
else {
temp->lhs_NC.list=org->lhs_NC.list;
temp->lhs_NC.type=org->lhs_NC.type;
temp->lhs_NC.inc=org->lhs_NC.inc;
temp->lhs_NC.link=org->lhs_NC.link;
//temp->lhs_NC=copy_NC(org->lhs_NC);
printf("&&&&&&&&&&&&&&&&&&&&&&&&&&&getting copied %s\n",string_NC(&temp->lhs_NC));
} */
temp->rhs=copy_NC(org->rhs);
return temp;
}
else return NULL;
}
/******************************************************************************************/

/*  This function is used to copy a data transition list                */
/*  It takes original data transition list as input and returns the pointer */
/*  to newly intiated and copied data from original data transition list                   */

/******************************************************************************************/

// copy a data transition list
DT_LIST *copy_DTLIST(DT_LIST *org){
if(org!=NULL){
DT_LIST *temp;
temp=(DT_LIST *)malloc(sizeof(DT_LIST));
temp->trans=copy_DTr(org->trans);
temp->next=copy_DTLIST(org->next);
return temp;
}
else return NULL;
}


/******************************************************************************************/

/*  This function is used to copy a data transition state                */
/*  It takes original data transition state as input and returns the pointer */
/*  to newly intiated and copied data from original data transition state                   */

/******************************************************************************************/

// copy a data transition state to another
TRANSITION_ST *copy_TST(TRANSITION_ST *org){
if(org==NULL) return NULL;
TRANSITION_ST *dest;
dest=create_TST();
dest->condition=copy_NC(org->condition);
dest->outtrans=org->outtrans;
dest->datatrans_cnt=org->datatrans_cnt;
dest->next=copy_TST(org->next);
int i=0;
while(i<dest->datatrans_cnt){
dest->action[i].lhs=org->action[i].lhs;
dest->action[i].flag=org->action[i].flag;
/* if(sizeof(dest->action[i].lhs)==sizeof(int))
	dest->action[i].lhs=org->action[i].lhs;
else{
	dest->action[i].lhs_NC.list=org->action[i].lhs_NC.list;
	dest->action[i].lhs_NC.type=org->action[i].lhs_NC.type;
	dest->action[i].lhs_NC.inc=org->action[i].lhs_NC.inc;
	dest->action[i].lhs_NC.link=org->action[i].lhs_NC.link;
}*/
dest->action[i].rhs=copy_NC(org->action[i].rhs);
i++;
}
return dest;
}


/******************************************************************************************/

/*  This function is used to print the entire FSMD data structure into a file                */
/*  It takes FSMD data structure and filename to be printed as input and           */
/*  writes the data transitions in the given format                */

/******************************************************************************************/

int start_state,end_state;
// printing entire FSMD data structure
void print_out(FSMD *fsm, char *filename){
modify_comments();
printf("enterd print function\n");
FILE *fout,*fout1;
char *file,*NCstr,*DTstr;
NCstr=(char *)malloc(sizeof(char)*100);
int i,j;
NODE_ST *temp;
TRANSITION_ST *temp1;
file=(char *)malloc(100);
sprintf(file,"%s.org",filename);
fout=fopen(file,"w");
fprintf(fout,"%s\n",file);
printf("%s\n",file);
sprintf(file,"%s1.org",filename);
fout1=fopen(file,"w");
fprintf(fout1,"\"%s\"\n",file);

fprintf(fout,"%d %d\n",input_count,output_count);
fprintf(fout1,"%d %d;\n",input_count,output_count);
printf("%d %d\n",input_count,output_count);
tmp=tmp1;
for(i=0;i<input_count;i++){
printf("%s ",tmp->idnt);
fprintf(fout,"%s ",tmp->idnt);
fprintf(fout1,"%s ",tmp->idnt);
tmp=tmp->next;
}
printf("\n");
fprintf(fout,"\n");
fprintf(fout1,";\n");
for(i=0;i<output_count;i++){
string_NC(rtrn->exprs,NCstr);
printf("%s ",NCstr);
fprintf(fout,"%s ",NCstr);
fprintf(fout1,"%s ",NCstr);
NCstr[0]='\0';
rtrn=rtrn->next;
}
printf("\n");
fprintf(fout,"\n");
fprintf(fout1,";\n");
for(i=0;i<MAXSTATES;i++)
if(fsm->states[i].node_type==START){
start_state=i;
temp=&fsm->states[i];
fprintf(fout,"%s %d",temp->state_id,temp->numtrans);
fprintf(fout1,"%s %d",temp->state_id,temp->numtrans);
printf("%s %d",temp->state_id,temp->numtrans);
temp1=temp->translist;
while(temp1!=NULL){
string_NC(temp1->condition,NCstr);
if(NCstr[0]=='\0'){
fprintf(fout," - / ");
fprintf(fout1," - | ");
printf(" - / ");
}
else{
fprintf(fout," %s / ",NCstr);
fprintf(fout1," %s | ",NCstr);
printf(" %s / ",NCstr);
}
//cleans(NCstr);
NCstr[0]='\0';
for(j=0;j<temp1->datatrans_cnt;j++){
DTstr=string_DTr(&temp1->action[j]);
if(DTstr==NULL){
fprintf(fout,"-");
fprintf(fout1,"-");
printf("-");
}
else{
fprintf(fout,"%s",DTstr);
fprintf(fout1,"%s",DTstr);
printf("%s",DTstr);
}
if(j!=temp1->datatrans_cnt-1) {
fprintf(fout,",");
fprintf(fout1,",");
printf(",");
}}
fprintf(fout,"\t%s\t",fsm->states[temp1->outtrans].state_id);
fprintf(fout1,"\t%s\t",fsm->states[temp1->outtrans].state_id);
printf("\t%s\t",fsm->states[temp1->outtrans].state_id);
temp1=temp1->next;
}
fprintf(fout1,"; %s\n",comments[i]);
fprintf(fout,"\n");
printf("\n");
}
for(i=0;i<MAXSTATES;i++)
if(i!=start_state){
if(fsm->states[i].node_type==END) { 
	end_state=i;
	printf("end state at %s\n",fsm->states[i].state_id);
	continue;
}
if(fsm->states[i].node_type==NORMAL){
temp=&fsm->states[i];
fprintf(fout,"%s %d",temp->state_id,temp->numtrans);
fprintf(fout1,"%s %d",temp->state_id,temp->numtrans);
printf("%s %d",temp->state_id,temp->numtrans);
temp1=temp->translist;
while(temp1!=NULL){
string_NC(temp1->condition,NCstr);
// printf("x=<%s>\n",NCstr);
if(NCstr[0]=='\0') {
fprintf(fout," - / ");
fprintf(fout1," - | ");
printf(" - / ");
}
else{
fprintf(fout," %s / ",NCstr);
fprintf(fout1," %s | ",NCstr);
printf(" %s / ",NCstr);
// NCstr=NULL;
}
NCstr[0]='\0';
//cleans(NCstr);
if(temp1->datatrans_cnt==0){
fprintf(fout,"- ");
fprintf(fout1,"- ");
printf("- ");
}
for(j=0;j<temp1->datatrans_cnt;j++){
DTstr=string_DTr(&temp1->action[j]);
if(DTstr==NULL){
fprintf(fout," - ");
fprintf(fout1," - ");
printf(" - ");
}
else {
fprintf(fout,"%s",DTstr);
fprintf(fout1,"%s",DTstr);
printf("%s",DTstr);
}
if(j!=temp1->datatrans_cnt-1) {
fprintf(fout,",");
fprintf(fout1,",");
printf(",");
}
}
fprintf(fout,"\t%s\t",fsm->states[temp1->outtrans].state_id);
fprintf(fout1,"\t%s\t",fsm->states[temp1->outtrans].state_id);
printf("\t%s\t",fsm->states[temp1->outtrans].state_id);
temp1=temp1->next;
}
fprintf(fout,"\n");
fprintf(fout1,"; \t%s\n",comments[i]);
printf("\n");
}
}
fprintf(fout,"%s %d\n\n\n",fsm->states[end_state].state_id,fsm->states[end_state].numtrans);
fprintf(fout1,"%s %d;\n\n\n",fsm->states[end_state].state_id,fsm->states[end_state].numtrans);
printf("%s %d\n\n\n",fsm->states[end_state].state_id,fsm->states[end_state].numtrans);
fclose(fout);
fclose(fout1);
printf("finished FSMD .org files\n");
}


/******************************************************************************************/

/*  This function is used to get the expression in string from nomalized form                */
/*  It takes Normalized tree as input and returns the pointer */
/*  to the string containing the expression                   */

/******************************************************************************************/

// get the string form of normalized expression 
void string_NC(NC *NCel, char *str){
// char *str;
// str=(char *)malloc(sizeof(char)*40);
NC *temp;temp=NCel;NC *temp1;
if(NCel==NULL) return;
if(NCel->type=='S'){
if(temp->inc==DIV){
	str[0]='(';
	++str;
	string_NC(temp->link,str);
	strcat(str,")/(");
	str+=strlen(str);
	string_NC(temp->link->list,str);
//		sprintf(str,"(%s)/(%s)",string_NC(temp->link),string_NC(temp->link->list));
		return;
		}
else if(temp->inc==MUL){
temp1=temp->link->list;
	str[0]='(';
	++str;
	string_NC(temp->link,str);
strcat(str,")");
// str+=strlen(str);
// sprintf(str,"(%s)",string_NC(temp->link));
while(temp1!=NULL){
strcat(str,"*(");
str+=strlen(str);
// sprintf(str,"%s*(%s)",str,string_NC(temp1));
string_NC(temp1,str);
strcat(str,")");

temp1=temp1->list;
}
return;
}
else if(temp->inc==ADD){
temp1=temp->link->list;
	string_NC(temp->link,str);
while(temp1!=NULL){
strcat(str,"+");
str+=strlen(str);
string_NC(temp1,str);
temp1=temp1->list;
}
return;
}
else if(temp->inc==SUB){
temp1=temp->link->list;
	string_NC(temp->link,str);
while(temp1!=NULL){
strcat(str,"-");
str+=strlen(str);
string_NC(temp1,str);
temp1=temp1->list;
}
return;
}
else if(temp->inc==REM) {
	string_NC(temp->link,str);
	strcat(str,"%");
	str+=strlen(str);
	string_NC(temp->link->list,str);
//	sprintf(str,"%s%%%s",string_NC(temp->link),string_NC(temp->link->list));
return;
}
else return;
}
else if(temp->type=='T'){
if(temp->link->type=='V'){
strcpy(str,current_table->bucket[temp->link->inc].symP);
 return;
}
else if(temp->link->type=='A'){
strcpy(str,current_table->bucket[temp->link->inc].symP);
str+=strlen(str);
//	sprintf(str,"%s",current_table->bucket[temp->link->inc].symP);
	temp1=temp->link->link;
	while(temp1!=NULL){
str[0]='[';
str++;
string_NC(temp1,str);
strcat(str,"]");
str+=strlen(str);
//	sprintf(str,"%s[%s]",str,string_NC(temp1));
	temp1=temp1->list;
	}
	return;
}
else return;
}
else if(temp->type=='R'){
if(temp->inc==LTR){
	string_NC(temp->link,str);
	strcat(str,"<");
	str+=strlen(str);
	string_NC(temp->link->list,str);
	return;
	}
else if(temp->inc==GTR){
	string_NC(temp->link,str);
	strcat(str,">");
	str+=strlen(str);
	string_NC(temp->link->list,str);
	return;
//	sprintf(str,"%s>%s",string_NC(temp->link),string_NC(temp->link->list));
//	return str;
	}
else if(temp->inc==LER){
	string_NC(temp->link,str);
	strcat(str,"<=");
	str+=strlen(str);
	string_NC(temp->link->list,str);
	return;
	}
else if(temp->inc==GER){
	string_NC(temp->link,str);
	strcat(str,">=");
	str+=strlen(str);
	string_NC(temp->link->list,str);
	return;
	}
else if(temp->inc==EQR){
	string_NC(temp->link,str);
	strcat(str,"==");
	str+=strlen(str);
	string_NC(temp->link->list,str);
	return;
	}
else if(temp->inc==NER){
	string_NC(temp->link,str);
	strcat(str,"!=");
	str+=strlen(str);
	string_NC(temp->link->list,str);
	return;
	}
else return;
}
else if(temp->type=='C'){
  sprintf(str,"%d",temp->inc);
  return;
}
else if(temp->type=='O'){
if (temp->inc==NEG){
str[0]='~';		// checkpoint
str++;
string_NC(temp->link,str);
//	sprintf(str,"~%s",string_NC(temp->link));
	return;
}
else if(temp->inc==ANDOP){
str[0]='(';
str++;
string_NC(temp->link,str);
temp1=temp->link->list;
while(temp1!=NULL){
strcat(str,") && (");
str+=strlen(str);
string_NC(temp1,str);
temp1=temp1->list;
}
strcat(str,")");
// 	sprintf(str,"(%s) && (%s)",string_NC(temp->link),string_NC(temp->link->list));
	return;
}
else if(temp->inc==OROP){
str[0]='(';
str++;
string_NC(temp->link,str);
temp1=temp->link->list;
while(temp1!=NULL){
strcat(str,") || (");
str+=strlen(str);
string_NC(temp1,str);
temp1=temp1->list;
}
strcat(str,")");
//	sprintf(str,"(%s) || (%s)",string_NC(temp->link),string_NC(temp->link->list));
	return;
}
else if(temp->inc==AND){
str[0]='(';
str++;
string_NC(temp->link,str);
temp1=temp->link->list;
while(temp1!=NULL){
strcat(str,") & (");
str+=strlen(str);
string_NC(temp1,str);
temp1=temp1->list;
}
strcat(str,")");
//	sprintf(str,"(%s) & (%s)",string_NC(temp->link),string_NC(temp->link->list));
	return;
}
else if(temp->inc==ORP){
str[0]='(';
str++;
string_NC(temp->link,str);
temp1=temp->link->list;
while(temp1!=NULL){
strcat(str,") | (");
str+=strlen(str);
string_NC(temp1,str);
temp1=temp1->list;
}
strcat(str,")");
//	sprintf(str,"(%s) | (%s)",string_NC(temp->link),string_NC(temp->link->list));
	return;
}
else if(temp->inc==NOT){
strcpy(str,"!(");
str+=strlen(str);
string_NC(temp->link,str);
strcat(str,")");
//  sprintf(str,"!(%s)",string_NC(temp->link));
	return;
}
else return;
}
else if(temp->type == 'f'){
strcpy(str,current_table->bucket[temp->inc].symP);
strcat(str,"(");
//	sprintf(str,"%s(",current_table->bucket[temp->inc].symP);
	if(temp->link!=NULL){
str+=strlen(str);
string_NC(temp->link,str);
//	sprintf(str,"%s%s",str,string_NC(temp->link));
	temp=temp->link->list;
	while(temp!=NULL){
strcat(str,",");
str+=strlen(str);
string_NC(temp,str);
//		sprintf(str,"%s,%s",str,string_NC(temp));
		temp=temp->list;
	}
}
strcat(str,")");
//	sprintf(str,"%s)",str);
	return;
}
else return;
}


/******************************************************************************************/

/*  This function is used to get the variable in string from                */
/*  It takes index of the variable as input and returns the pointer */
/*  to the string containing the variable : applies even to arrays                   */

/******************************************************************************************/

// to get the variable string form from index
char *variable(int inc){
char *str,*str1;
str=(char *)malloc(sizeof(char)*100);
str1=(char *)malloc(sizeof(char)*100);
int rm,jj=inc,k,i=0,j1;
symtab *table;table=current_table;
if(inc<table->count) {
if(table->bucket[inc].dim==0)
return table->bucket[inc].symP;
else{
sprintf(str,"%s",table->bucket[inc].symP);
for(jj=0;jj<table->bucket[inc].dim;jj++)
	sprintf(str,"%s[0]",str);
return str;
}}
else {
  i=0;rm=jj/1000;
  jj%=1000;str = NULL;
  sprintf(str1,"%s",table->bucket[jj].symP);
  while(i<table->bucket[jj].dim){
    k=1;j1=table->bucket[jj].dim-1;
    while(j1>i){
      k*=table->bucket[jj].ar[j1];
      j1--;
    }
    sprintf(str1,"%s[%d]",str1,rm/k);
    rm%=k;i++;
  }
  return str1;
}
}


/******************************************************************************************/

/*  This function is used to get the string form of data transition                */
/*  It takes original data transition expression as input and returns the pointer */
/*  to string form of it                    */

/******************************************************************************************/

// get the string form of data transition expression
char *string_DTr(DATA_TRANS *action){
if(action==NULL) return NULL;
char *temp,*NCstr,*varP;
varP=(char *)malloc(sizeof(char)*100);
NCstr=(char *)malloc(sizeof(char)*100);
temp=(char *)malloc(sizeof(char)*100);
//printf("\nhello %d %d\n",action->lhs,action->flag);
if(action->flag==FALSE) varP=variable(action->lhs);
else { string_NC(action->lhs_NC,varP);
// printf("\nentered \n");
// print_NC(action->lhs_NC);
// printf("string : %s %s\n",varP,string_NC(action->lhs_NC));
// exit(1);
}

/* if(sizeof(action->lhs)==sizeof(int)){
//	printf("hi 2 : %d\n",action->lhs);
	varP=variable(action->lhs);
}
else {
printf("hi\n");
varP=string_NC(&action->lhs_NC);
printf("~~~~~~~~~~~~~~~~~~~~~ NC lhs : %s\n",varP);
exit(1);
}*/
string_NC(action->rhs,NCstr);
sprintf(temp,"%s=%s",varP,NCstr);
//free(varP);
//free(NCstr);
return temp;
}


void copy_lNC(NC A,NC B){//trans1->action[i].lhs_NC,list->trans->lhs_NC){
printf("in copy_lNC : \n");
A.link=B.link;
A.inc=B.inc;
A.type=B.type;
A.list=B.list;
/*
printf("%d %d\n",A.inc,B.inc);
printf("%c %c\n",A.type,B.type);
if(B.link!=NULL){
printf("link : %d %d\n",A.link->inc,B.link->inc);
printf("link : %c %c\n",A.link->type,B.link->type);
print_NC(A.link);
printf("\nasda\n");
print_NC(B.link);
}
if(B.list!=NULL){
printf("list : %d %d\n",A.list->inc,B.list->inc);
printf("list : %c %c\n",A.list->type,B.list->type);
print_NC(A.list);
}
exit(1);*/
}



void modify_comments(){
int i=0; char *temp_str1,*temp_str2;
temp_str1=(char*)malloc(100*sizeof(char));
temp_str2=(char*)malloc(100*sizeof(char));
TRANSITION_ST *temp;
printf("/**LELB situations will be handled here**/\n");
printf("time_stamp : state_id comments\n");
for(i=0;i<MAXSTATES;i++)
if(strcmp(comments[i],"2")==0){
temp=c2f->states[i].translist;
temp=temp->next;
if(strlen(c2f->states[temp->outtrans].state_id)!=4+strlen(temps)){
printf("*****************LELB situation : \n");
printf("intially : %s : %s\n",c2f->states[temp->outtrans].state_id,comments[temp->outtrans]);
strcpy(temp_str1,c2f->states[temp->outtrans].state_id);
strncpy(temp_str2,c2f->states[temp->outtrans].state_id,4+strlen(temps));
temp_str2[4+strlen(temps)]='\0';
temp_str1+=4+strlen(temps);
strcat(temp_str2,"LE");
strcat(temp_str2,temp_str1);
strcpy(c2f->states[temp->outtrans].state_id,temp_str2);
strcpy(temp_str1,comments[temp->outtrans]);
strcpy(comments[temp->outtrans],"/* loop_end */");
strcat(comments[temp->outtrans],temp_str1);
printf("finally : %s : %s\n",c2f->states[temp->outtrans].state_id,comments[temp->outtrans]);
printf("**********************************\n");
}
else {
	strcat(c2f->states[temp->outtrans].state_id,"LE");
	strcat(comments[temp->outtrans],"/* loop_end */");
	}
strcpy(comments[i],"\0");
}
}


int check_NC(NC *t){
	if(t==NULL) return 0;
	else if(t->type == 'U') return -1;
	else return check_NC(t->list) + check_NC(t->link);
}



p_lisT *copy_lisT(p_lisT *inp){
p_lisT *temp,*outp;
if(inp==NULL) return NULL;
outp=(p_lisT*)malloc(sizeof(p_lisT));
temp=outp;
while(inp->next!=NULL){
outp->idnt=(char*)malloc(sizeof(char)*strlen(inp->idnt));
strcpy(outp->idnt,inp->idnt);
outp->vart=inp->vart;
outp->index=inp->index;
outp->next=(p_lisT*)malloc(sizeof(p_lisT));
outp=outp->next;
inp=inp->next;
}
outp->idnt=(char*)malloc(sizeof(char)*strlen(inp->idnt));
strcpy(outp->idnt,inp->idnt);
outp->vart=inp->vart;
outp->index=inp->index;
return temp;
}

void intialize_state(int state_count){
sprintf(c2f->states[state_count].state_id,"%s%d",temps,1000+state_count);
c2f->states[state_count].node_type=NORMAL;
c2f->numstates++;
return;
}



#ifdef DOTTY

void print_dotty(char *filename){
char *file;
l2=l1;
print_lisT(l2);
int i;
file=(char*)malloc(sizeof(char)*50);
sprintf(file,"HTG_%s_c_main.dotty",filename);
FILE *fout3;
fout3=fopen(file,"w");

fprintf(fout3,"digraph routine\n{\nfontname = \"Times-Roman\"; fontsize = 14;\n");
fprintf(fout3,"nodesep = 0.1; ranksep = 0.5;\nnode [height = 0.25, width = 0.4, shape = %s ];\n",shapes[1]);
fprintf(fout3,"edge [color = %s ];\n",colors[0]);
printf("loop count : %d\n",loop_count);
loops=(int**)malloc(sizeof(int*)*loop_count);
for(i=0;i<loop_count;i++)
	loops[i]=(int*)malloc(sizeof(int)*3);
string_clusters=(char**)malloc(sizeof(char*)*loop_count);
for(i=0;i<loop_count;i++)
	string_clusters[i]=(char*)malloc(sizeof(char)*15000);
printf("hi allocations succesful\nloops sorting & merging :\n");
for(i=0;i<loop_count;i++){
loops[i][2]=1;
string_loop(l2,i);
if(l2->type==IFEL) l2=l2->next;
l2=l2->next;
}
printf("loops sorted\n");
// sort_loops();	//sorts the list
int a,b,c;
a=start_state;b=start_state;

while(b!=end_state){
printf("<%d,%d,%d,%d>\n",start_state,end_state,a,b);
a=b;
if((c=check_loop(a))!=-1){
fprintf(fout3,"%s",string_clusters[c]);
printf("loop inserted : %d %d\n",loops[c][0],loops[c][1]);
b=loops[c][1];
loops[c][2]=0;
}
else{
if(c2f->states[a].numtrans==2){
printf("error %d %d %d\n",a,b,start_state);
}
fprintf(fout3,"%s",print_node(a,NODE));
b=c2f->states[a].translist->outtrans;
}
}
printf("Ok till here : loops modifications succesful\n");

fprintf(fout3,"node%s [color=%s shape=%s,label=\"{%s : data_transitions=0\\n}\"];\n",c2f->states[b].state_id,colors[2],shapes[0],c2f->states[b].state_id);
//fprintf(fout3,"%s\n",print_node(b,NODE));
printf("Ok till here : nodes are added \nLinks now :\n");
for(i=0;i<MAXSTATES;i++)
if(c2f->states[i].node_type!=UNDEF){
if(c2f->states[i].numtrans==1){
fprintf(fout3,"node%s -> node%s [label=\"\"];\n",c2f->states[i].state_id,c2f->states[c2f->states[i].translist->outtrans].state_id);
}
else if(c2f->states[i].numtrans==2){
fprintf(fout3,"node%s -> node%s [label=\"T\"];\n",c2f->states[i].state_id,c2f->states[c2f->states[i].translist->outtrans].state_id);
fprintf(fout3,"node%s -> node%s [label=\"F\"];\n",c2f->states[i].state_id,c2f->states[c2f->states[i].translist->next->outtrans].state_id);
}
else if(c2f->states[i].numtrans==0) {printf("end state reached : %d\n",i);}
else printf("error : %d\n",i);
}
printf("links too finished\n");
fprintf(fout3,"\n}\n\n\n");
printf("Generated output file names : HTG_%s_c_main.dotty %s.org %s1.org\n",filename,filename,filename);
fclose(fout3);

printf("dotty finished\n");
}


char *print_node(int node,int type){
char *temp;
temp=(char*)malloc(1000*(sizeof(char)));
// printf("hi print <%d,%d>\n",node, type);
if(type==CONDN){
sprintf(temp,"node%s [color=%s shape=%s,label=\"{%s : data_transitions=0\\n",c2f->states[node].state_id,colors[2],shapes[0],c2f->states[node].state_id);
sprintf(temp,"%s|?%s\\n",temp,modify_string_print(c2f->states[node].translist->condition));
}
else {
sprintf(temp,"node%s [color=%s shape=%s,label=\"{%s : data_transitions=%d\\n",c2f->states[node].state_id,colors[2],shapes[0],c2f->states[node].state_id,c2f->states[node].numtrans);
TRANSITION_ST *tt;int i;
tt=c2f->states[node].translist;
for(i=0;i<tt->datatrans_cnt;i++)
	sprintf(temp,"%s|%s\\n",temp,string_DTr(&tt->action[i]));
}
strcat(temp,"}\"];\n");
return temp;
}


char *modify_string_print(NC *N){
char *temp,*temp1,*temp2;
temp=(char *)malloc(sizeof(char)*100);
string_NC(N,temp);
temp1=(char*)malloc(sizeof(char)*(4+strlen(temp)));
temp2=temp1;
while(temp[0]!='\0'){
if(temp[0]=='<' || temp[0]=='>') {temp2[0]='\\';++temp2;}
temp2[0]=temp[0];
++temp2;
++temp;
}
temp2[0]='\0';
return temp1;
}


// int loops[loop_count][4];
void string_loop(loopi *loop,int i){
int a,b,c,j;
if(loop->type==IFL){
a=loop->start;
loops[i][0]=a;
b=c2f->states[a].translist->next->outtrans;
loops[i][1]=b;
printf("if <%d,%d> ",loops[i][0],loops[i][1]);
sprintf(string_clusters[i],"subgraph cluster_if_IF%d  { color=%s; label=\"IF%d\";\n",if_count,colors[1],if_count);
if_count++;
j=c2f->states[a].translist->outtrans;
strcat(string_clusters[i],print_node(a,CONDN));
printf("sizes :");
while(j!=b){
if((c=check_loops(j,i))==-1){
strcat(string_clusters[i],print_node(j,NODE));
j=c2f->states[j].translist->outtrans;
}
else{
printf(" <%d,%d>",strlen(string_clusters[i]),strlen(string_clusters[c]));
strcat(string_clusters[i],string_clusters[c]);
// free(string_clusters[c]);
j=loops[c][1];
loops[c][2]=0;
}
}
strcat(string_clusters[i],"}\n");
printf("<%d,%d,%d> ",loops[i][0],loops[i][1],loops[i][2]);
}
else if(loop->type==IFEL){
a=loop->start;
loops[i][0]=a;
b=find_end(a,loop->end);
printf("ifel <%d,%d> ",loops[i][0],loops[i][1]);
if(b==-1) exit(1);
loops[i][1]=b;
sprintf(string_clusters[i],"subgraph cluster_ifelse_IFELSE%d  { color=%s; label=\"IFELSE%d\";\n",ifel_count,colors[1],ifel_count);
ifel_count++;
j=c2f->states[a].translist->outtrans;
strcat(string_clusters[i],print_node(a,CONDN));
printf("sizes :");
while(j!=b){
if((c=check_loops(j,i))==-1){
strcat(string_clusters[i],print_node(j,NODE));
j=c2f->states[j].translist->outtrans;
}
else{
printf(" <%d,%d>",strlen(string_clusters[i]),strlen(string_clusters[c]));
strcat(string_clusters[i],string_clusters[c]);
// free(string_clusters[c]);
j=loops[c][1];
loops[c][2]=0;
}
}

j=c2f->states[a].translist->next->outtrans;
//strcat(string_clusters[i],print_node(a,CONDN));
while(j!=b){
if((c=check_loops(j,i))==-1){
strcat(string_clusters[i],print_node(j,NODE));
j=c2f->states[j].translist->outtrans;
}
else{
printf(" <%d,%d>",strlen(string_clusters[i]),strlen(string_clusters[c]));
strcat(string_clusters[i],string_clusters[c]);
// free(string_clusters[c]);
j=loops[c][1];
loops[c][2]=0;
}
}
strcat(string_clusters[i],"}\n");
printf("sizes end <%d,%d,%d> ",loops[i][0],loops[i][1],loops[i][2]);
}
else {
a=loop->start1;
loops[i][0]=a;
b=c2f->states[a].translist->next->outtrans;
loops[i][1]=b;
printf("loop <%d,%d> ",loops[i][0],loops[i][1]);
strcpy(string_clusters[i],print_node(a,CONDN));
sprintf(string_clusters[i],"%ssubgraph cluster_loop_LOOP%d  { color=%s; label=\"LOOP%d\";\n",string_clusters[i],loopl_count,colors[1],loopl_count);
loopl_count++;
j=c2f->states[a].translist->outtrans;
printf("sizes :");
while(j!=a){
if((c=check_loops(j,i))==-1){
strcat(string_clusters[i],print_node(j,NODE));
// printf("loop : %d -> %d\n",j,c2f->states[j].translist->outtrans);
j=c2f->states[j].translist->outtrans;
}
else{
printf(" <%d,%d>",strlen(string_clusters[i]),strlen(string_clusters[c]));
strcat(string_clusters[i],string_clusters[c]);
// free(string_clusters[c]);
j=loops[c][1];
loops[c][2]=0;
}
}
strcat(string_clusters[i],"}\n");
printf("sizes end <%d,%d,%d> ",loops[i][0],loops[i][1],loops[i][2]);
}
printf("end\n");
return;
}

int check_loop(int node){
int i=0;
for(i=0;i<loop_count;i++){
if(loops[i][0]==node){
if(loops[i][2]==1) return i;
printf("some error : %d %d %d\n",loops[i][0],loops[i][1],loops[i][2]);
exit(1);
}
}
return -1;
}


int check_loops(int node, int pos){
int i=0;
while(i<pos){
if(loops[i][0]==node)
	return i;
i++;
}
return -1;
}


int find_end(int node,int endl){
int z;
z=c2f->states[node].translist->next->outtrans;
if(c2f->states[z].translist->outtrans==endl)
	return endl;
int y,A[100],B[100],i,a=0,b=0;
y=c2f->states[node].translist->outtrans;
A[a]=y;B[b]=z;
while(a<99 && b<99){
for(i=0;i<=a;i++)
	if(A[i]==B[b]) return A[i];
for(i=0;i<=b;i++)
	if(A[a]==B[i]) return A[a];
a++;b++;
A[a]=c2f->states[A[a-1]].numtrans==2 ? c2f->states[A[a-1]].translist->next->outtrans:c2f->states[A[a-1]].translist->outtrans;
B[b]=c2f->states[B[b-1]].numtrans==2 ? c2f->states[B[b-1]].translist->next->outtrans:c2f->states[B[b-1]].translist->outtrans;
}
printf("error : please increase arrays :A,B sizes in function  find_end and re run\n");
return  -1;
}


void print_lisT(loopi *tmp){
printf("loop list :\n");
while(tmp!=NULL){
printf("<%d,%d,%d,%d>\n",tmp->start,tmp->start1,tmp->end,tmp->type);
tmp=tmp->next;
}
printf("end\n");
}

#endif

void cleans(char *st){
int i=strlen(st);
while(i>0){
st[i]='\0';
i--;
}
return;
}

