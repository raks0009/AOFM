//diffeq qq  //<file_name> <state_name>

#include<stdio.h>
unsigned int dieffq()
{
//int x, y, u, a, dx;
int t1, t2, t3, t4, t5, t6, y1,i;
unsigned int x, y, u, a, dx;
int xout, yout, uout;
for(i=0;x<a;i=i+1)
{
t1=u*dx;
t2=3*x;
t3=3*y;
t4=t1*t2;
t5=dx*t3;
t6=u-t4;
u=t6-t5;
y1=u*dx;
y=y+y1;
x=x+dx;
}
xout=x;
yout=y;
uout=u;
return xout;
}
