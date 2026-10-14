// ----------------------------------------------
// File: idcttop.v
// Module: idcttop
// Function:Inverse DCT top module
// ----------------------------------------------

module idcttop (
     clkdec,       
     rstdec_x,     
     c_mbpl_idct_r_s,
     q_blkstp_r_s,   
     q_do_r,         
     t_idcto_r      
            );

     input            clkdec;   
     input            rstdec_x;  
     input            c_mbpl_idct_r_s;
     input            q_blkstp_r_s;
     input     [11:0] q_do_r;
    output      [8:0] t_idcto_r;

      wire            LDTM0WEC81NF         ;
      wire            LDTM1WEC81NF         ;
      wire     [15:0] idctod               ;
      wire [5:0]  v1_trp00_a; 
      wire        v1_trp00_bs; 
      wire [15:0] v1_trp00_d;
      wire        v1_trp00_we; 
      wire [15:0] w1_trp00_q;
      wire [5:0]  v1_trp01_a; 
      wire        v1_trp01_bs; 
      wire [15:0] v1_trp01_d;
      wire        v1_trp01_we; 
      wire [15:0] w1_trp01_q;
      wire [15:0] syncpp;

idct_dcttp  idct_dcttp (
     .DCTMOD81PF(1'b0),             
     .LDTM0DOX81DD(w1_trp00_q),     
     .LDTM1DOX81DD(w1_trp01_q),     
     .rstdec_x(rstdec_x),          
     .SIGXIN81DD({q_do_r,4'h0}),  
     .STARTN81PP(q_blkstp_r_s),   
     .clkdec(clkdec),              
     .DSYNCX81PP(syncpp),                 
     .LDTM0ADD81DD(v1_trp00_a),     
     .LDTM0DIN81DD(v1_trp00_d),     
     .LDTM0WEC81NF(LDTM0WEC81NF),   
     .LDTM1ADD81DD(v1_trp01_a),     
     .LDTM1WEC81NF(LDTM1WEC81NF),   
     .SIGOUT81DD(idctod)            
);

idct_round  idct_round (
     .clkdec(clkdec),   
     .di(idctod),               
     .rstdec_x(rstdec_x),
     .do_r(t_idcto_r)          
);

idct_seqmbs  idct_seqmbs (
     .LDTM0WEC81NF(LDTM0WEC81NF),
     .LDTM1WEC81NF(LDTM1WEC81NF),
     .clkdec(clkdec), 
     .rstdec_x(rstdec_x),
     .c_mbpl_idct_r_s(c_mbpl_idct_r_s),
     .v1_trp00_bs(v1_trp00_bs),
     .v1_trp00_we(v1_trp00_we),
     .v1_trp01_bs(v1_trp01_bs),
     .v1_trp01_we(v1_trp01_we)
);

idct_trparray idcttrp(
   .clkdec       (clkdec),
   .rstdec_x     (rstdec_x),
   .v1_trp00_a   (v1_trp00_a),
   .v1_trp00_bs  (v1_trp00_bs),
   .v1_trp00_d   (v1_trp00_d),
   .v1_trp00_we  (v1_trp00_we),
   .w1_trp00_q   (w1_trp00_q),
   .v1_trp01_a   (v1_trp01_a),
   .v1_trp01_bs  (v1_trp01_bs),
   .v1_trp01_d   (syncpp),
   .v1_trp01_we  (v1_trp01_we),
   .w1_trp01_q   (w1_trp01_q)
   );

endmodule

