 # C2FSMD Tool
By Rathan Kumar

### Instructions 
command lines : 

	make
	./myparser < $$.c
	
* output :	

	* $$.org		// normal output
	* $$1.org		// modified output

*  $$.c format should be :
	<//$1 $2
	 <c_code>
	>
	
	* $1 : FSMD name that has to be given
	* $2 : State name

## output files
 * general (org) : outputs resulting from previously defined grammar.
 * modified  (org) : outputs resulting from modified grammar.
 * dotty : FSMD data structre in dotty format.
 * comments (txt) : which are printed in the terminal while running a particular c code.
