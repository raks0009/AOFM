//sac_sparkout r
//extern void chk_SAC(unsigned *);

void chk_SAC()
{
 unsigned sbox[100];
 unsigned x;
 unsigned xi;
 unsigned vi;
 unsigned i;
 unsigned bit_index;
 unsigned count_0s[8];
 unsigned count_1s[8];
 int sT0_12;
 int sT1_14;
 int sT2_21;
 unsigned sT3_22;
 unsigned sT4_22;
 int sT5_25;
 unsigned sT6_26;
 unsigned sT7_26;
 int sT8_26;
 int sT9_26;
 int sT10_32;
 int sT11_21;

  x = 0;
  while(x <= 255)
     {
      bit_index = 0;
      while(bit_index < 8)
         {
          count_0s[bit_index] = 0;
          count_1s[bit_index] = 0;
          bit_index = (bit_index + 1);
         }          /* end of loop condition */

      i = 1;
      sT4_22 = (sbox[x]);
      do  {
          xi = power(x,i);
          sT3_22 = (sbox[xi]);
          vi = power(sT4_22,sT3_22);
          bit_index = 0;
          while(bit_index < 8)
             {
              sT9_26 = g( vi,1,bit_index);
              if(sT9_26!=0)
               {
                count_1s[bit_index] = (count_1s[bit_index] + 1);
               } /* sT9_26               */
              else
               {
                count_0s[bit_index] = (count_0s[bit_index] + 1);
               }  /* end of if-else (sT9_26)*/
              bit_index = (bit_index + 1);
             }              /* end of loop condition */

          i = leftShift(i,1);
         }while(i!=f(1,8));          /* end of loop condition */
 
     }

    return;
}
