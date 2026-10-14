// ----------------------------------------------
// File: idct_romx0.v
// Module: idct_romx0
// Function:
// ----------------------------------------------

module idct_romx0(
    DAH, 
    DAL, 
    ADRH, 
    ADRL, 
    MD
);

output [16:0]  DAH;  
output [17:0]  DAL;  
input  [15:0]  ADRH; 
input  [15:0]  ADRL; 
input  MD;           

reg [16:0]  DAH;
reg [17:0]  DAL;
reg [17:0]  rom_15, rom_14, rom_13, rom_12, rom_11, rom_10, 
            rom_9, rom_8,rom_7, rom_6, rom_5, rom_4, 
            rom_3, rom_2, rom_1, rom_0;

always @(MD) begin
  if (MD == 1'b1) begin /*  DCT  */
    rom_0  =     0;
    rom_1  =  8192;
    rom_2  =  8192;
    rom_3  = 16384;
    rom_4  =  8192;
    rom_5  = 16384;
    rom_6  = 16384;
    rom_7  = 24576; 
    rom_8  =  8192;
    rom_9  = 16384;
    rom_10  = 16384;
    rom_11  = 24576;
    rom_12  = 16384;
    rom_13  = 24576;
    rom_14  = 24576;
    rom_15  = 32767;
  end
  else if (MD == 1'b0) begin /*  IDCT  */
    rom_0  =     0;
    rom_1  =  8192;
    rom_2  = 10703;
    rom_3  = 18895;
    rom_4  =  8192;
    rom_5  = 16384;
    rom_6  = 18895;
    rom_7  = 27087; 
    rom_8  =  4433;
    rom_9  = 12626;
    rom_10  = 15137;
    rom_11  = 23329;
    rom_12  = 12626;
    rom_13  = 20818;
    rom_14  = 23329;
    rom_15  = 31521;
  end
  else begin
    rom_0  = 18'bx;
    rom_1  = 18'bx;
    rom_2  = 18'bx;
    rom_3  = 18'bx;
    rom_4  = 18'bx;
    rom_5  = 18'bx;
    rom_6  = 18'bx;
    rom_7  = 18'bx;
    rom_8  = 18'bx;
    rom_9  = 18'bx;
    rom_10  = 18'bx;
    rom_11  = 18'bx;
    rom_12  = 18'bx;
    rom_13  = 18'bx;
    rom_14  = 18'bx;
    rom_15  = 18'bx;
  end
end

always @(ADRH or rom_0 or rom_1 or rom_2 or rom_3 or rom_4 or rom_5 or rom_6 or rom_7 or rom_8 or rom_9 or rom_10 or rom_11 or rom_12 or rom_13 or rom_14 or rom_15) begin
   if(ADRH[0]==1'b1)      DAH = rom_0;
   else if(ADRH[1]==1'b1) DAH = rom_1;
   else if(ADRH[2]==1'b1) DAH = rom_2;
   else if(ADRH[3]==1'b1) DAH = rom_3;
   else if(ADRH[4]==1'b1) DAH = rom_4;
   else if(ADRH[5]==1'b1) DAH = rom_5;
   else if(ADRH[6]==1'b1) DAH = rom_6;
   else if(ADRH[7]==1'b1) DAH = rom_7;
   else if(ADRH[8]==1'b1) DAH = rom_8;
   else if(ADRH[9]==1'b1) DAH = rom_9;
   else if(ADRH[10]==1'b1) DAH = rom_10;
   else if(ADRH[11]==1'b1) DAH = rom_11;
   else if(ADRH[12]==1'b1) DAH = rom_12;
   else if(ADRH[13]==1'b1) DAH = rom_13;
   else if(ADRH[14]==1'b1) DAH = rom_14;
   else if(ADRH[15]==1'b1) DAH = rom_15;
   else                    DAH = rom_0;
 end

always @(ADRL or rom_0 or rom_1 or rom_2 or rom_3 or rom_4 or rom_5 or rom_6 or rom_7 or rom_8 or rom_9 or rom_10 or rom_11 or rom_12 or rom_13 or rom_14 or rom_15) begin
   if(ADRL[0]==1'b1)      DAL = rom_0;
   else if(ADRL[1]==1'b1) DAL = rom_1;
   else if(ADRL[2]==1'b1) DAL = rom_2;
   else if(ADRL[3]==1'b1) DAL = rom_3;
   else if(ADRL[4]==1'b1) DAL = rom_4;
   else if(ADRL[5]==1'b1) DAL = rom_5;
   else if(ADRL[6]==1'b1) DAL = rom_6;
   else if(ADRL[7]==1'b1) DAL = rom_7;
   else if(ADRL[8]==1'b1) DAL = rom_8;
   else if(ADRL[9]==1'b1) DAL = rom_9;
   else if(ADRL[10]==1'b1) DAL = rom_10;
   else if(ADRL[11]==1'b1) DAL = rom_11;
   else if(ADRL[12]==1'b1) DAL = rom_12;
   else if(ADRL[13]==1'b1) DAL = rom_13;
   else if(ADRL[14]==1'b1) DAL = rom_14;
   else if(ADRL[15]==1'b1) DAL = rom_15;
   else                    DAL = rom_0;
end

endmodule

