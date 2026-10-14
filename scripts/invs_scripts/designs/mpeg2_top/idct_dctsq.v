// ----------------------------------------------
// File: idct_dctsq.v
// Module: idct_dctsq
// Function:
// ----------------------------------------------

module idct_dctsq(
        MODEIN, 
        GODCT, 
        rstdec_x, 
        clkdec,
        CSFTPR, 
        CPRDI1, 
        CPRDI2, 
        CPRDI3, 
        CPRDI4, 
        CTMOD1, 
        CTMOD2, 
        CTMOD3, 
        CPBTF, 
        CPLOAD, 
        CPRCT1, 
        CPRCT2, 
        CPRCT3, 
        CPRCT4, 
        CPRCT5, 
        CPRCT6, 
        CPRCT7, 
        CPRCT8, 
        CACSGN, 
        SDAO0, 
        SDAO1, 
        SDAO2, 
        SDAO3, 
        SDAO4, 
        SDAO5, 
        SDAO6, 
        SDAO7, 
        CACRST, 
        VDCT, 
        CPSMOD, 
        CPSADD, 
        MODEOUT, 
        GOTRN
);

input  MODEIN;  
input  GODCT;   
input  rstdec_x;   
input  clkdec;     
output CSFTPR;  
output CPRDI1;  
output CPRDI2;  
output CPRDI3;  
output CPRDI4;  
output CTMOD1;  
output CTMOD2;  
output CTMOD3;  
output CPBTF;   
output CPLOAD;  
output CPRCT1;  
output CPRCT2;  
output CPRCT3;  
output CPRCT4;  
output CPRCT5;  
output CPRCT6;  
output CPRCT7;  
output CPRCT8;  
output CACSGN;  
output SDAO0;   
output SDAO1;   
output SDAO2;   
output SDAO3;   
output SDAO4;   
output SDAO5;   
output SDAO6;   
output SDAO7;   
output CACRST;  
output VDCT;    
output CPSMOD;  
output CPSADD;  
output MODEOUT; 
output GOTRN;   

parameter   c_size = 3'd6;
parameter   r_size = 7'd64;

reg              prev_go;
reg              dct_mode;
reg              SDAO0, SDAO1, SDAO2, SDAO3;
reg              SDAO4, SDAO5, SDAO6, SDAO7;
reg              cpsadd_reg1, cpsadd_reg2;
reg              GOTRN;
reg              next_ready, nr_sel;
reg              c5,c4,c3,c2,c1,c0;
wire [c_size-1:0] muxout;
wire             cpsadd_reg;
wire             mdin_sel;
wire             CSFTPR;
wire             cnt_start; 
wire             go_next;
wire [c_size:0]  incout;


always @(posedge clkdec or negedge rstdec_x ) begin
   if( !rstdec_x )
       prev_go <= 1'b0;
   else
       prev_go <= GODCT;
end

assign cnt_start = GODCT & ~prev_go;

always @(GODCT or go_next or next_ready) begin
   if(GODCT==1'b1)
       nr_sel = 1'b1;
   else if(go_next==1'b1)   
       nr_sel = 1'b0;
   else
       nr_sel = next_ready;
end

always @(posedge clkdec or negedge rstdec_x ) begin
   if( !rstdec_x )
     next_ready <= 1'b0;
   else
     next_ready <= nr_sel;
end


function  [c_size:0] incr_64;
    input [c_size:0] d;
    begin
        if (d >= r_size - 1)
              incr_64 = 7'b0;
        else
              incr_64 = d[5:0] + 6'b1;
    end
endfunction

assign muxout = (cnt_start == 1'b1) ? 6'd0:incout[5:0];

always @(posedge clkdec or negedge rstdec_x) begin
    if(!rstdec_x)
         {c5,c4,c3,c2,c1,c0} <= 0;
    else
         {c5,c4,c3,c2,c1,c0} <= muxout;
end

assign incout = incr_64 ({1'b0,c5,c4,c3,c2,c1,c0});

assign CPRDI1 = ~c1 & ~c0;
assign CPRDI2 = ~c1 &  c0; 
assign CPRDI3 =  c1 & ~c0;
assign CPRDI4 =  c1 &  c0;

assign MODEOUT = dct_mode;

assign mdin_sel = (cnt_start == 1'b1) ? MODEIN:dct_mode;

always @(posedge clkdec or negedge rstdec_x) begin
    if(!rstdec_x)
         dct_mode <= 0;
    else
         dct_mode <= mdin_sel;
end

assign CSFTPR = (dct_mode == 1'b1) ? ~c2:1'b1;

assign CTMOD1 = dct_mode;
assign CTMOD2 = dct_mode;
assign CTMOD3 = dct_mode;

assign CPBTF = c2 & ~c1 & c0 |  c2 &  c1 & ~c0 |
               c2 &  c1 & c0 | ~c2 & ~c1 & ~c0;
     
assign CPLOAD =  c2 & ~c1 & ~c0;
assign CPRCT1 =  c2 & ~c1 & ~c0;
assign CPRCT2 =  c2 & ~c1 &  c0;
assign CPRCT3 =  c2 &  c1 & ~c0;
assign CPRCT4 =  c2 &  c1 &  c0;
assign CPRCT5 = ~c2 & ~c1 & ~c0;
assign CPRCT6 = ~c2 & ~c1 &  c0;
assign CPRCT7 = ~c2 &  c1 & ~c0;
assign CPRCT8 = ~c2 &  c1 &  c0;
assign CACSGN =  c2 &  c1 & ~c0; 

always @(dct_mode or c0 or c1 or c2) begin
    if(dct_mode==1'b1)begin
        SDAO0 = ~c2 & ~c1 & c0;
        SDAO1 = ~c2 & c1 & c0;
        SDAO2 = c2 & ~c1 & c0;
        SDAO3 = c2 & c1 & c0;
        SDAO4 = ~c2 & c1 & ~c0;
        SDAO5 = c2 & ~c1 & ~c0; 
        SDAO6 = c2 & c1 & ~c0; 
        SDAO7 = ~c2 & ~c1 & ~c0;
    end
    else begin
        SDAO0 = ~c2 & ~c1 &  c0 |~c2 & ~c1 & ~c0;
        SDAO1 = ~c2 &  c1 & ~c0 | c2 &  c1 &  c0;
        SDAO2 = ~c2 &  c1 &  c0 | c2 &  c1 & ~c0;
        SDAO3 =  c2 & ~c1 & ~c0 | c2 & ~c1 &  c0;
        SDAO4 = ~c2 & ~c1 &  c0 |~c2 & ~c1 & ~c0;
        SDAO5 = ~c2 &  c1 & ~c0 | c2 &  c1 &  c0; 
        SDAO6 = ~c2 &  c1 &  c0 | c2 &  c1 & ~c0;
        SDAO7 =  c2 & ~c1 & ~c0 | c2 & ~c1 &  c0;
    end
end

 assign CACRST = ~c2 & ~c1 & ~c0;
 assign VDCT = dct_mode;
 assign CPSMOD = dct_mode;

assign cpsadd_reg = (dct_mode == 1'b1) ? 1'b1:
      ~c2 & ~c1 & ~c0 |~c2 & ~c1 & c0 |~c2 & c1 & ~c0 |~c2 & c1 & c0;

always @(posedge clkdec or negedge rstdec_x) begin
    if(!rstdec_x) begin
        cpsadd_reg2 <= 1'b0;
        cpsadd_reg1 <= 1'b0;
        GOTRN <= 1'b0;
    end
    else begin
        cpsadd_reg2 <= cpsadd_reg1;
        cpsadd_reg1 <= cpsadd_reg;
        GOTRN <= go_next;
    end
end

assign CPSADD = cpsadd_reg2;

assign go_next = (~c5 & c4 & c3 & ~c2 & c1 & c0) & next_ready;


endmodule

