//pc q
void chk_PC(){
   unsigned int sbox[100];
   unsigned int x,xi,vi;
   unsigned int i,bit_index;
   unsigned int bit_no,count_0s[8],count_1s[8];
  

/*   if((fp=fopen("log_PC.txt","w"))==NULL){
      printf("\nCannot open SAC log file");
      exit(1);
   } */

   for(bit_index = 0; bit_index<8; bit_index=bit_index+1){
      count_0s[bit_index] = 0;
      count_1s[bit_index] = 0;
   }
  
   //fprintf(fp,"Propagation Criteria of degree 1 (SAC):\n");
   for(bit_no = 0;bit_no < 8;bit_no=bit_no+1){

      //fprintf(fp,"\n\n**** Complement bit no: %d ********************************************************************************\n",bit_no);

      for(i=0; i<leftShift(1,8); i=i+1){  // Iterate over input space x: 0x00->0xff
         x  = i;
         xi = xorLShift(x,1,bit_no);
         vi = xor(sbox[x],sbox[xi]);
     
         for(bit_index = 0; bit_index<8; bit_index=bit_index+1){          
            if( andLShift(vi,1,bit_index)!=0 ) count_1s[bit_index]=count_1s[bit_index]+1;
            else count_0s[bit_index]=count_0s[bit_index]+1;
         }

      }

   }

/*      for(bit_index = 0; bit_index<8; bit_index++){
         fprintf(fp,"\n\nBit %d: count_0s = %3d, count_1s = %3d, Pr(bit flipped) = %f",bit_index,count_0s[bit_index],count_1s[bit_index],(float)(count_1s[bit_index])/(count_1s[bit_index]+count_0s[bit_index]));
      }

   printf("\n");
   fclose(fp); */
   return ;
}
