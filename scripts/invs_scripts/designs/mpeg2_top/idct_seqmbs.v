// ----------------------------------------------
// File: idct_seqmbs.v
// Module: idct_seqmbs
// Function:take adjustment of 
//               Legacy IP and a memory module 
// ----------------------------------------------

module idct_seqmbs
  (
   clkdec,
   rstdec_x,
   c_mbpl_idct_r_s,
   LDTM0WEC81NF,
   LDTM1WEC81NF,
   v1_trp00_bs,
   v1_trp01_bs,
   v1_trp00_we,
   v1_trp01_we
   );

  input     clkdec;  
  input     rstdec_x;
  input     c_mbpl_idct_r_s;    //mbsync
  input     LDTM0WEC81NF;       //write enable
  input     LDTM1WEC81NF;       //write enable
  output    v1_trp00_bs;        //block select
  output    v1_trp01_bs;        //block select
  output    v1_trp00_we;        //write enable
  output    v1_trp01_we;        //write enable

  reg       mbsync_r_s;
  reg [4:0] mbdelay_r;
  reg [9:0] bs_cnt_r;
  reg       v1_trp00_bs;
  reg       v1_trp01_bs;
  
  wire      mbsync_de_s;
  
  
  always@( posedge clkdec or negedge rstdec_x ) begin
    if( !rstdec_x )
      mbsync_r_s <= 1'b0;
    else
      mbsync_r_s <= c_mbpl_idct_r_s;
  end
  
  always@( posedge clkdec or negedge rstdec_x ) begin
    if( !rstdec_x )
      mbdelay_r <= 5'd0;
    else begin
      if( mbsync_r_s )
        mbdelay_r <= 5'd0;
      else if( mbdelay_r == 5'd16 )
        mbdelay_r <= mbdelay_r;
      else
        mbdelay_r <= mbdelay_r + 5'd1;
    end
  end

  assign mbsync_de_s = ( mbdelay_r == 5'd15 ) ? 1'b1 : 1'b0;
    
  always@( posedge clkdec or negedge rstdec_x ) begin
     if( !rstdec_x )
       bs_cnt_r <= 10'd0;
     else begin 
       if( mbsync_de_s )
         bs_cnt_r <= 10'd0;
       else if( bs_cnt_r == 10'd513 )
         bs_cnt_r <= bs_cnt_r;
       else
         bs_cnt_r <= bs_cnt_r + 10'd1;
    end
  end

  always@( posedge clkdec or negedge rstdec_x ) begin
    if( !rstdec_x )
      begin
        v1_trp00_bs <= 1'b0;
        v1_trp01_bs <= 1'b0;
      end
    else begin
      if( 10'd0 <= bs_cnt_r && bs_cnt_r <= 10'd512 )
        begin
          v1_trp00_bs <= 1'b1;
          v1_trp01_bs <= 1'b1;
        end
      else
        begin
          v1_trp00_bs <= 1'b0;
          v1_trp01_bs <= 1'b0;
        end
    end
  end
   
  assign v1_trp00_we = ~LDTM0WEC81NF;
  assign v1_trp01_we = ~LDTM1WEC81NF;

endmodule


