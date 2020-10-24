myparser:	lex.yy.o c2fsmd.tab.o
		gcc -Wall -g lex.yy.o c2fsmd.tab.o -o myparser
c2fsmd.tab.o:	c2fsmd.tab.c
		gcc -Wall -c -g c2fsmd.tab.c
lex.yy.o:	lex.yy.c c2fsmd.tab.h
		gcc -Wall -c -g lex.yy.c
c2fsmd.tab.c:	c2fsmd.y
		bison -d -v c2fsmd.y
c2fsmd.tab.h:	c2fsmd.y	
		bison -d -v c2fsmd.y
lex.yy.c:	c2fsmd.l
		flex c2fsmd.l
clean:
		rm myparser lex.yy.o c2fsmd.tab.tab.o c2fsmd.tab.c c2fsmd.tab.h lex.yy.c
