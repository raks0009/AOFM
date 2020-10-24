//paperO q

#include <stdio.h>

void original()
{

int i, a[10][10], dL, dR, dD;
int rT[10], rE[10], rO[10], rP[10], rnP[10];

for(i = 0; i <= n; i += 1) {
   dL = dL + a[i][i];
   dR = dR + a[i][n-i];
   dD = dD + (dL - dR);
   for(j = 0; j <= n; j += 1) {
      rT[i] = rT[i] + a[i][j];
      if(even(a[i][j]))
         rE[i] = rE[i] + a[i][j];
      else {
         rO[i] = rO[i] + a[i][j];
         if(prime(a[i][j]))
            rP[i] = rP[i] + a[i][j];
         else
            rnP[i] = rnP[i] + a[i][j];
      }
  }

return;
}
