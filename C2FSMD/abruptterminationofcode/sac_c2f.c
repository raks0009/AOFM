//sac q
void chk_SAC(){
   unsigned int sbox[100];
   unsigned int x,xi,vi;
   unsigned int i,bit_index;
   unsigned int bit_no,count_0s[8],count_1s[8];
  
   for(x = 0;x <= 255;x=x+1){

      for(bit_index = 0;bit_index<8;bit_index=bit_index+1){
         count_0s[bit_index] = 0;
         count_1s[bit_index] = 0;
      }
 
      i=0;

      do{ 
         xi = power(x,i);
         vi = power(sbox[x],sbox[xi]);
     
         for(bit_index = 0;bit_index<8;bit_index++){          
            if( g(vi,1,bit_index)!=0 ) count_1s[bit_index]=count_1s[bit_index]+1;
            else count_0s[bit_index]=count_0s[bit_index]+1;
         }

         i = leftShift(i,1);
      }while(i!=f(1,8));
   }

   return ;
}
