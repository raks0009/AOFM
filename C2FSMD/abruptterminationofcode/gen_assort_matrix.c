//gen_assort_matrix q

#include <stdio.h>

void gen_assort_matrix_bi(int l, int m, int n, int frac_low)
{
  int assort_matrix[100][100], temp ;
  int i = 0, j = 0 , total = 1, nl = 0, nm = 0;
  int sum_deg_l = 0 , sum_deg_m = 0 , total_edges = 0;;

  for(i = 1 ; i < m+1 ; i=i+1)
  {
     for(j = 1 ; j<i+1 ; j=j+1)
      assort_matrix[i][j] = 0 ;
  }
  nl = frac_low* n;
  nm = n - nl ;
  sum_deg_l = l*nl;
  sum_deg_m = m*nm;
  total_edges = (sum_deg_l + sum_deg_m ) /2 ;
  if(sum_deg_l > sum_deg_m)
  {
    //temp = ((sum_deg_m*100/total_edges)/2)/100 ;
temp = ((sum_deg_m*100/total_edges)*2)*100 ;
    assort_matrix[m][m] = temp;    
    assort_matrix[l][m] = sum_deg_m*1 /total_edges - 2*assort_matrix[m][m] ;
    assort_matrix[m][l] = sum_deg_m*1 /total_edges - 2*assort_matrix[m][m] ;
    assort_matrix[l][l] =  assort_matrix[m][m] + (sum_deg_l - sum_deg_m)/(2*total_edges);
  }
  else
  {
    //temp = ((sum_deg_l*100/total_edges)/2)/100 ;
temp = ((sum_deg_l*100/total_edges)*2)*100 ;
    assort_matrix[l][l] = temp;
    assort_matrix[l][m] = sum_deg_l*1 /total_edges - 2*assort_matrix[l][l] ;
    assort_matrix[m][l] = sum_deg_l*1 /total_edges - 2*assort_matrix[l][l] ;
    assort_matrix[m][m] =  assort_matrix[l][l] + (sum_deg_m - sum_deg_l)/(2*total_edges);
  }

  return;
}


/*
int main(){
	gen_assort_matrix_bi(0,0,0,0);
}*/
