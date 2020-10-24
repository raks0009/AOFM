#ifndef HEADER
#define HEADER

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define DOTTY

#define BUCKET_COUNT 250
#define MAXSTATES 1000
#define Int 4
#define Float 8
#define Funt 10
#define Stor 6
#define Char 1
#define USE 2
#define START 100
#define NORMAL 101
#define END 102
#define UNDEF 103
#define TRUES 105
#define FALSES 106
#define VARB 1
#define MAXVALS 100

// arithematic operators
#define MUL 99
#define DIV 98
#define ADD 97
#define SUB 96
#define REM 95
#define INC 94
#define DEC 93
#define INCP 92
#define DECP 91

// relational operators
#define LTR 89
#define GTR 88
#define EQR 87
#define NER 86
#define LER 85
#define GER 84

// logical operators
#define ORP 79
#define AND 78
#define OROP 77
#define ANDOP 76
#define XOR 75
#define NOT 74
#define NEG 73

// assignment operators
#define EQU 60
#define ELF 59
#define ERF 58

// loop types
#define FORL 1
#define WHILEL 2
#define IFL 3
#define IFEL 4
#define CONDN 5
#define NODE 6


#define YES 1
#define NO 0
#define COMP_TEMP 2
#define OK 0
#define NOT_DEF -2
#define RE_DEF 2
#define DEF 1
#define IDK -1

#define ERP -1


/******************************************************************************************/

/*      This is the header file which contain the definitions    */
/*      and the prototypes of the functions which were used for  */
/*      the verification of the scheduling                       */


/******************************************************************************************/

typedef struct normalized_cell NC;

struct normalized_cell
{
   NC *list;
   char type;
   int inc;
   NC *link;
};


enum BOOLEAN{
	FALSE=0,
	TRUE,
};


/*    This structure is used to hold the information of an assignment operation */
typedef struct Assign
{
enum BOOLEAN flag;
union 
{
   int lhs;    /* left hand side (lhs) variable's symbol table index is stored here  */
   NC *lhs_NC;
   // lhs part getting trouble in implementation of arrays
};
   
   NC *rhs;  /* right hand side of the assignment is stored as an expression tree */
}DATA_TRANS;



/*  This structure hold the information of each transition of the FSMD  */
typedef struct trans_struct   
{
	NC    *condition;    /*  transition condition */
	
	DATA_TRANS  action[40];      /*  actions to be perfomed during transition */
	
	int datatrans_cnt;	/* no. of data transitions */
	
	int  outtrans;     
	/*  this is the pointer *to the resulting state after transition */ 
	
        struct	trans_struct  *next;
	/* This is the pointer to the next transition of the same state  */
	
} TRANSITION_ST; 
/*  TRANSITION_ST is the name of the structure for transition  */



/*  This holds the complete infomation of a state in the FSMD    */
typedef struct state_struct
{
	char  state_id[25];  /*  this is the name of the structure  */
	
	int   node_type; 
	 
	/*  this is the type of the state,it may be start state or 
	 *  final state or any cutpoint or any other state          */
	
	int   numtrans; /*this holds the number of transitions of that state */
	
        TRANSITION_ST  *translist;
	/* this is the list of all transitions from this state  */
	
//	struct state_struct *next;
	/* this is the pointer to the next state by name in the FSMD  */
	
}NODE_ST;  /* This is the structure for a state */

  /*  NODE_ST is the name of the structure holding the state information   */


typedef struct fsmd_struct 
{
	char name[50];
	
	int  numstates;

	NODE_ST  states[MAXSTATES];
}FSMD;


//  each variable information as a node form
typedef struct symNode{
	char *symP;	// variable name
	int data_type;	// variable data type
	int defined;	// variable defined type
	int *val;	// variable values : even array list
	int *ar;	// array range list ( dimension range list)
	int dim;	// array dimension
}symnode;

// symbol table containing all the variables
typedef struct symbol_table symtab;

struct symbol_table{
	symnode bucket[BUCKET_COUNT];
	int count;
	symtab *upTab, *downTab;
};



/* This structure is used to hold the information regarding the variables of the FSMD's
*/
typedef struct variables{

  int var_val[200]; // integer value of the variable
  char *var_string[200]; // variable
  int no_of_elements; // no of elements in the list
}var_list;


/* this is a data structure containing list of normalized expressions */
typedef struct intializer_list LIST;
struct intializer_list
{
	NC *exprs;
	LIST *next;
};


/* this is a data structure containing list of data transition expressions */
typedef struct dataT_list DT_LIST;
struct dataT_list
{
	DATA_TRANS *trans;
	DT_LIST *next;
};

typedef struct param_list p_lisT;
struct param_list
{
	char *idnt;
	int vart;
	int index;
	p_lisT *next;
};

/* list of declared data types of non terminals in yyparse */

typedef struct prnsS
{
	int prev;
	int next;
}prnsS;

typedef struct typelS
{
	char str[20];
	int vart;
}typelS;

typedef struct unopS
{
	char str[5];
	int op;
}unopS;

typedef struct dclrnS
{
	char *str;
	int prev;
	int next;
}dclrnS;

typedef struct ptrcntS
{
	char str[10];
	int cnt;
}ptrcntS;

typedef struct expresoS
{
	NC *NCell;
	DATA_TRANS *DTr;
	int inc;
}expresoS;

typedef struct exprsnS
{
	NC *NCell;
	DT_LIST *DTL;
	int inc;
}exprsnS;

typedef struct dtlsS
{
	char *str;
	DT_LIST *DTL;
}dtlsS;

typedef struct nclsS
{
	char *idnt;
	char *str;
	LIST *lst;
}nclsS;


typedef struct epxrsstsS
{
	DT_LIST *DTL;
	int prev;
	int next;
	NC *NCell;
}epxrsstsS;

typedef struct loopinfo loopi;
struct loopinfo
{
	int start;
	int start1;
	int end;
	int type;
	loopi *next;
};

typedef struct val_list val;
struct val_list
{
	NC N[MAXVALS];
	int i;
};


/*  list of declarations of functions from c2fsmd.y  */
NC* modify(NC *);
void modify_comments();
NC *link_NC(NC *,NC *,int );
int fvalue(char *,int );
void split(int ,int );
void addexpr(DT_LIST *,int );
NC* create_term(char *);
NC* create_NC();
int getvalue(int );
int indexoftable(char *);
void INfsmd(NODE_ST *,int ,NC *,DT_LIST *);
TRANSITION_ST *create_TST();
FSMD *newFSMD();
DT_LIST *searchinsert(char *,LIST *,LIST *,int );
symtab *newSymTab(symtab *);
NC *NNC(NC *);
LIST *create_list();
DATA_TRANS* create_DT(NC *,NC *);
void print_NC(NC *);
int value_NC(NC *);
NC *copy_NC(NC *);
char *string_DTr(DATA_TRANS *);
char *variable(int );
void string_NC(NC *,char *);
void print_out(FSMD *, char *);
int get_index(NC *);
int array_index(NC *,int );
LIST *copy_LIST(LIST *);
DT_LIST *copy_DTLIST(DT_LIST *);
DT_LIST *link_DTLIST(DT_LIST *,DT_LIST *);
DATA_TRANS *copy_DTr(DATA_TRANS *);
TRANSITION_ST *copy_TST(TRANSITION_ST* );
void copy_lNC(NC , NC);
char *line_count(int );
void print_dotty(char *);
int check_NC(NC *);
void intialize_state(int );
void print_lisT(loopi *);
p_lisT *copy_lisT(p_lisT *);
void nameit(char *,char *);
void cleans(char *);

#ifdef DOTTY
void print_dotty(char *);
char *print_node(int ,int );
char *modify_string_print(NC *);
void string_loop(loopi *,int );
int check_loop(int );
int check_loops(int , int );
int find_end(int ,int );
#endif

#endif

