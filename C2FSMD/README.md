{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf600
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # C2FSMD Tool\
By Rathan Kumar\
\
### Instructions \
command lines : \
\
	make\
	./myparser < $$.c\
\
* output :	\
	$$.org		// normal output\
	$$1.org		// modified output\
\
*  $$.c format should be :\
	<//$1 $2\
	 <c_code>\
	>\
\
	* $1 : FSMD name that has to be given\
	* $2 : State name\
\
\
\
## output files \
	* genera (org) : outputs resulting from previously defined grammar.\
	* modified  (org) : outputs resulting from modified grammar.\
	* dotty : fsmd data structre as in dotty format.\
	* comments (txt) : which are printed in the terminal while running a particular c code.}