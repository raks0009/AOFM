//test gg

#include <stdio.h>

#define NOTHING
int test();

int main()
{
	int y1, y2;
	int z;
	z = test();
	while (y1 != y2)
	{
		y1 = y1 / y2;
	}
	return z;
}

int test()
{
	int y1, y2;
	y1 = 5;
	return y1;
}