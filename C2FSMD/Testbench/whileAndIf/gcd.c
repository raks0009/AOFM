//gcd gg

#include <stdio.h>
int gcd_modified()
{
	int y1, y2;
	int z;
	int i = 5;
	while (y1 != y2)
	{
		if (y1 > 100)
			y1 = y1 / y2;
		else
			y2 = (y2 - y1) % 100 - 5;
	}
	return z;
}
