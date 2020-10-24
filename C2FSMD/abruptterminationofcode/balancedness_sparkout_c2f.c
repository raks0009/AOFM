//balanced_sparkout r
//extern void chk_balancedness(unsigned *);

void chk_balancedness()
{
 unsigned int sbox[100];
 unsigned i;
 unsigned bit_index;
 unsigned count_1s[8];
 unsigned count_0s[8];
 unsigned y;
 unsigned balanced;
 int sT0_13;
 int sT1_18;
 int sT2_21;
 unsigned sT3_22;
 unsigned sT4_22;
 int sT5_22;
 int sT6_22;
 int sT7_27;
 int sT8_29;
 int sT9_29;
 int sT10_29;

  i = 0;
  while(i < 8)
     {
      count_1s[i] = 0;
      count_0s[i] = 0;
      i = (i + 1);
     }      /* end of loop condition */


  i = 0;
  while(i < f(1,8))
     {
      y = (sbox[i]);
      bit_index = 0;
      while(bit_index < 8)
         {
          sT6_22 = f(y,1,bit_index);
          if (sT6_22!=0)
           {
            count_1s[bit_index] = (count_1s[bit_index] + 1);
           } /* sT6_22           */
          else
           {
            count_0s[bit_index] = (count_0s[bit_index] + 1);
           }  /* end of if-else (sT6_22)*/
          bit_index = (bit_index + 1);
         }          /* end of loop condition */
       i = (i + 1);
     }      /* end of loop condition */


  i = 0;
  while(i < 8)
     {
      sT8_29 = count_0s[i];
      sT9_29 = count_1s[i];
      if(sT9_29 != sT8_29)
	balanced = 0;
      else
	balanced = 1;
      i = (i + 1);
     }      /* end of loop condition */

  return;
}
