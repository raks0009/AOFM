//pc_sparkout r
//extern void chk_PC(unsigned *);

void chk_PC()
{
 unsigned sbox[100];
 unsigned x;
 unsigned xi;
 unsigned vi;
 unsigned i;
 unsigned bit_index;
 unsigned bit_no;
 unsigned count_0s[8];
 unsigned count_1s[8];
 int sT0_13;
 int sT1_19;
 int sT2_23;
 unsigned sT3_24;
 unsigned sT4_24;
 unsigned sT5_24;
 unsigned sT6_24;
 int sT7_28;
 unsigned sT8_29;
 unsigned sT9_29;
 int sT10_29;
 int sT11_29;
 unsigned sT12_29;
 unsigned sT13_30;

  bit_index = 0;
  while(bit_index < 8)
     {
      count_0s[bit_index] = 0;
      count_1s[bit_index] = 0;
      bit_index = (bit_index + 1);
     }      /* end of loop condition */

  bit_no = 0;
  while(bit_no < 8)
     {
      i = 0;
      sT3_24 = leftShift(1,bit_no);
      while(i < sT3_24)
         {
          xi = xorLShift(x,1,bit_no);
          sT5_24 = (sbox[xi]);
          sT6_24 = (sbox[i]);
          vi = xor(sT6_24,sT5_24);
          bit_index = 0;
          while(bit_index < 8)
             {
              sT11_29 = andLShift(vi,1,bit_index);
              if (sT11_29!=0)
               {
                sT12_29 = count_1s[bit_index];
                count_1s[bit_index] = (sT12_29 + 1);
               } /* sT11_29               */
              else
               {
                sT13_30 = count_0s[bit_index];
                count_0s[bit_index] = (sT13_30 + 1);
               }  /* end of if-else (sT11_29)*/
              bit_index = (bit_index + 1);
             }              /* end of loop condition */

          i = (i + 1);
         }          /* end of loop condition */

      bit_no = (bit_no + 1);
     }      /* end of loop condition */

  return;
}
