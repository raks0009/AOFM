/*
		C2FSMD Lexer
*/

%{

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "header.h"
#include "c2fsmd.tab.h"


extern YYSTYPE yylval;
int lineno=0;
int column = 0;
extern int yylineno;
char *stringLiteral();
int check_type();
void count();
void comment();
void comment2();
void comment3();

%}


D				[0-9]
L				[a-zA-Z_]
H				[a-fA-F0-9]
E				[Ee][+-]?{D}+
FS				(f|F|l|L)
IS				(u|U|l|L)*


%%
"/*"				{ comment(); }
"//"				{ comment2(); }
"#"				{ comment3(); }

"auto"			{ count(); return(AUTO); }
"break"			{ count(); return(BREAK); }
"case"			{ count(); return(CASE); }
"char"			{ count(); return(CHAR); }
"const"			{ count(); return(CONST); }
"continue"		{ count(); return(CONTINUE); }
"default"			{ count(); return(DEFAULT); }
"do"				{ count(); return(DO); }
"double"			{ count(); return(DOUBLE); }
"else"			{ count(); return(ELSE); }
"enum"			{ count(); return(ENUM); }
"extern"			{ count(); return(EXTERN); }
"float"			{ count(); return(FLOAT); }
"for"			{ count(); return(FOR); }
"goto"			{ count(); return(GOTO); }
"if"				{ count(); return(IF); }
"int"			{ count(); return(INT); }
"long"			{ count(); return(LONG); }
"register"		{ count(); return(REGISTER); }
"return"			{ count(); return(RETURN); }
"short"			{ count(); return(SHORT); }
"signed"			{ count(); return(SIGNED); }
"sizeof"			{ count(); return(SIZEOF); }
"static"			{ count(); return(STATIC); }
"struct"			{ count(); return(STRUCT); }
"switch"			{ count(); return(SWITCH); }
"typedef"		{ count(); return(TYPEDEF); }
"union"			{ count(); return(UNION); }
"unsigned"		{ count(); return(UNSIGNED); }
"void"			{ count(); return(VOID); }
"volatile"			{ count(); return(VOLATILE); }
"while"			{ count(); return(WHILE); }


{L}({L}|{D})*		{ count(); 
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return (check_type());
					}

0[xX]{H}+{IS}?		{ count();
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(STOR_CONSTANT); 
					}
					
0{D}+{IS}?			{ count();/*yylval.integer=atoi(yytext);*/
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(CONSTANT);
					}
					
{D}+{IS}?			{ count();/*yylval.integer=atoi(yytext);*/
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(CONSTANT);
					}
					
L?'(\\.|[^\\'])+'		{ count();/*yylval.real=atof(yytext);*/
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(FLOAT_CONSTANT);
					}

{D}+{E}{FS}?		{ count();/*yylval.integer=atoi(yytext);*/
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(CONSTANT);
					}
				
{D}*"."{D}+({E})?{FS}?	{ count();/*yylval.real=atof(yytext);*/
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(FLOAT_CONSTANT); 
					}
			
{D}+"."{D}*({E})?{FS}?	{ count();/*yylval.real=atof(yytext);*/
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(FLOAT_CONSTANT); 
					}

L?\"(\\.|[^\\"])*\"		{ count(); /*strcpy(yylval.str,yytext); */
					yylval.str=(char *)malloc((yyleng+1)*(sizeof(char)));
					strncpy(yylval.str, yytext, yyleng + 1);
					return(STRING_LITERAL);
					}

"..."				{ count(); return(ELLIPSIS); }
">>=" 			{ count(); return(RIGHT_ASSIGN); }
"<<=" 			{ count(); return(LEFT_ASSIGN) ; }
"+="  			{ count(); return(ADD_ASSIGN)  ; }
"-="  			{ count(); return(SUB_ASSIGN)  ; }
"*="  			{ count(); return(MUL_ASSIGN)  ; }
"/="  			{ count(); return(DIV_ASSIGN)  ; }
"%="  			{ count(); return(MOD_ASSIGN)  ; }
"&="  			{ count(); return(AND_ASSIGN)  ; }
"^="  			{ count(); return(XOR_ASSIGN)  ; }
"|="  			{ count(); return(OR_ASSIGN)   ; }
">>"			{ count(); return(RIGHT_OP); }
"<<"			{ count(); return(LEFT_OP); }
"++"			{ count(); return(INC_OP); }
"--"				{ count(); return(DEC_OP); }
"->"				{ count(); return(PTR_OP); }
"&&"			{ count(); return(AND_OP); }
"||"				{ count(); return(OR_OP); }
"<="			{ count(); return(LE_OP); }
">="			{ count(); return(GE_OP); }
"=="			{ count(); return(EQ_OP); }
"!="				{ count(); return(NE_OP); }
";"				{ count(); return(';'); }
("{"|"<%")		{ count(); return('{'); }
("}"|"%>")		{ count(); return('}'); }
","				{ count(); return(','); }
":"				{ count(); return(':'); }
"="				{ count(); return('='); }
"("				{ count(); return('('); }
")"				{ count(); return(')'); }
("["|"<:")			{ count(); return('['); }
("]"|":>")			{ count(); return(']'); }
"."				{ count(); return('.'); }
"&"				{ count(); return('&'); }
"!"				{ count(); return('!'); }
"~"				{ count(); return('~'); }
"-"				{ count(); return('-'); }
"+"				{ count(); return('+'); }
"*"				{ count(); return('*'); }
"/"				{ count(); return('/'); }
"%"				{ count(); return('%'); }
"<"				{ count(); return('<'); }
">"				{ count(); return('>'); }
"^"				{ count(); return('^'); }
"|"				{ count(); return('|'); }
"?"				{ count(); return('?'); }

[ \t\v\f]			{ count(); }
[\n]				{ 	count(); ++lineno; }

.				{ /* ignore bad characters */ }

%%
int yywrap()
{
	return(1);
}


void comment()
{
	//for handling multiple line /*comments*/
	char c, c1;

	c=input();
while(1){
if(c=='*'){
	c1=input();
	if(c1 == '/')
		break;
	c=c1;
	continue;
}
if(c == '\n'){
	++lineno;
	c=c1;
	continue;
}
c=input();
}

/* loop:
	while ((c = input()) != '*' && c != 0 )
	{
		;
	}
	if( c!= 0 )
		c1 = input();
	if( c1 != 0 && c1 != '/' )
		goto loop;
*/
}

void comment3()
{
	//for handling //one line comments and #directives
	char c,writePorts[100];
	static int i = 0;
	if( (c=input()) == '@' )
	{
		for(; (c=input())!='\n' && c!=0; i++)
			writePorts[i] = c;

		writePorts[i]='\0';
	}
	else
		while((c=input())!='\n' && c!=0)
			;
	++lineno;
}

void comment2()
{
	char c;
if(lineno!=0){
while((c=input())!='\n'){}
}
else {
char fsmdname[20],statename[20];
int i=0;
while((c=input())!='\n' && c!=' '){
fsmdname[i]=c;
i++;
}
fsmdname[i]='\0';
i=0;
while((c=input())!='\n' && c!=' '){
statename[i]=c;i++;
}
statename[i]='\0';
nameit(fsmdname,statename);
while(c!='\n'){c=input();}
}
++lineno;
}

void  count() {
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
			column++;
	/*ECHO;*/
}


char strLitBuff[2048];

char *stringLiteral ()
{
       int ch;
       char *str = strLitBuff ;
       
       *str++ = '\"'   ;
       /* put into the buffer till we hit the */
       /* first \" */
       while (1) {

      	ch = input() ;
          if (!ch) 	    
          	break	; /* end of input */
          
	 	 /* if it is a \ then everything allowed */
	  	if (ch == '\\') {
	     	*str++ = ch ; 				/* backslash in place */
	     	*str++ = input() ; 			/* following char in place */
	     	continue ;      			/* carry on */
	     }
	     
	 	/* if new line we have a new line break */
		if (ch == '\n')
		 	break ;
	 
	 	/* if this is a quote then we have work to do */
	 	/* find the next non whitespace character     */
	 	/* if that is a double quote then carry on    */
	 	if (ch == '\"') {
	 
	     	while ((ch = input()) && isspace(ch)) ;
	     
	     	if (!ch) 
	     		break ; 
	     	
	     	if (ch != '\"') {
	    			unput(ch) ;
		  		break ;
			}
		  
			continue ;
   		}
   		
		*str++  = ch;	  
     }  
     *str++ = '\"'	;
     *str = '\0';
     return strLitBuff ;
}

int check_type()
{
/*
* pseudo code --- this is what it should check
*
*	if (yytext == type_name)
*		return(TYPE_NAME);
*
*	return(IDENTIFIER);
*/

/*
*	it actually will only return IDENTIFIER
*/

	return(IDENTIFIER);
}

char *line_count(int inp){
	char *temp_str;
	temp_str=(char*)malloc(20*sizeof(char));
	sprintf(temp_str,"%d",lineno+1);
	return temp_str;
}
