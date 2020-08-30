#!/bin/bash

working_dir=$1

i=1
#mkdir "cluster$i"
#mv "solution.c" "cluster$i/representative.c"
#((i=i+1))

for f in ./*.c; do
	echo "$f"
	
	if [ ! -d "cluster1" ]; then
#		echo "no"
#	else:
#		echo "yes"
#	fi
#	dirList=$(ls -d cluster* | wc -l)	
#	if [ $dirList == 0 ]; then
		mkdir "cluster$i"
		mv "$f" "cluster$i/representative.c"
		((i=i+1))
		#echo "i=$i"
	else
		flag=0
		for dir in ./cluster*; do
			#echo "dir=$dir"
			Pc="$dir/representative.c"
			out=$($working_dir/eqChkAddg "$Pc" "$f")
			
				
				if [[ $out == *"The two programs are equivalent"* ]]; then
					mv "$f" "$dir/$f"
					flag=1
					break
				fi
			
			#echo "out: $out"
			#echo "$dir", "$Pc"
		done
		echo "$i"
		if [ "$flag" == 0 ]; then
			if [ ! -d "cluster$i" ]; then
				mkdir "cluster$i"
				mv "$f" "cluster$i/representative.c"
				((i=i+1))
			fi
		fi
	fi

	
	#((i=i+1))
	#echo "$i"	
done
#echo "$j"

$working_dir/plotting_clusters.py $PWD
$working_dir/marks_cluster.py $PWD

