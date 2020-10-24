//balanced q
void chk_balancedness(int z){

   unsigned int sbox[100];
   unsigned int i,bit_index,count_1s[8],count_0s[8];
   
   unsigned int y, balanced;
	z=10;
   for(i=0; i <8; i=i+1){
      count_1s[i] = 0;
      count_0s[i] = 0;
   }
  
   for(i=0; i < f(1,8); i=i+1){
      y = sbox[i];
      
      for(bit_index=0; bit_index<8; bit_index=bit_index+1){
         if( f2(y,1,bit_index)!=0 ) count_1s[bit_index]=count_1s[bit_index]+1;
         else count_0s[bit_index]=count_0s[bit_index]+1; 
      }
   }

   for(i=0; i <8; i=i+1){
       if(count_1s[i]!=count_0s[i]) 
       { balanced = 0; }
       else 
       { balanced = 1; }
   }

    return;
}

