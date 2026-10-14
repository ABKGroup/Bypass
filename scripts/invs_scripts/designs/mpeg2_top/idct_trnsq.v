// ----------------------------------------------
// File: idct_trnsq.v
// Module: idct_trnsq
// Function:
// ----------------------------------------------

module idct_trnsq(
       MODEIN, 
       GOTRN, 
       GOTEST, 
       rstdec_x, 
       clkdec,
       LDTM0ADD81DD, 
       LDTM1ADD81DD, 
       LDTM0WEC81NF, 
       LDTM1WEC81NF, 
       OEC1, 
       OEC2,
       MODEOUT, 
       GONEXT 
          );

input  MODEIN;              
input  GOTRN;               
input  GOTEST;              
input  rstdec_x;               
input  clkdec;                 
output [5:0]  LDTM0ADD81DD; 
output [5:0]  LDTM1ADD81DD; 
output LDTM0WEC81NF;        
output LDTM1WEC81NF;        
output OEC1;                
output OEC2;                
output MODEOUT;             
output GONEXT;              
 
 reg    st_reg;
 reg    mdin_sel, dct_mode;
 reg    md_reg1, md_reg2, md_reg3;
 reg    m1read_reg, m2read_reg;
 reg    nx_reg1, nx_reg2, nx_reg3;
 reg    cnt_sel, cnt_reg;
 reg    init_cnt;
 reg    m1_sel, m1_reg;
 reg    m2_sel, m2_reg;
 reg    next_ready1, nr1_sel;
 reg    next_ready2, nr2_sel;


 wire   m1rst, m1read, m1c5, m1c4, m1c3, m1c2, m1c1, m1c0;
 wire   m2rst, m2read, m2c5, m2c4, m2c3, m2c2, m2c1, m2c0;
 wire   go_wire;
 wire   m1_cut, m2_cut, m_cut;
 wire   start_m1, start_m2;
 wire   m1_sync, m2_sync;

 assign go_wire = GOTRN | GOTEST;

 always @(posedge clkdec) begin
  st_reg <= go_wire;
 end

 always @(st_reg or MODEIN or dct_mode) begin
  case (st_reg)
   1'b1   : mdin_sel = MODEIN;
   1'b0   : mdin_sel = dct_mode;
  endcase
 end

 always @(posedge clkdec) begin
  dct_mode <= mdin_sel;
 end

 always @(posedge clkdec) begin
  md_reg3 <= md_reg2;
  md_reg2 <= md_reg1;
  md_reg1 <= dct_mode;
 end

 assign MODEOUT = md_reg3;

 always @(posedge clkdec) begin
  m1read_reg <= m1read;
  m2read_reg <= m2read;
 end


 assign LDTM0WEC81NF = m1read_reg;
 assign LDTM1WEC81NF = m2read_reg;
 assign OEC1 = ~m1read_reg;
 assign OEC2 = ~m2read_reg | m1read_reg;

 assign m1_cut = (~m1read & m1c5 & m1c4 & m1c3 & m1c2 & m1c1 & ~m1c0) & next_ready1;
 assign m2_cut = (~m2read & m2c5 & m2c4 & m2c3 & m2c2 & m2c1 & ~m2c0) & next_ready2;
 assign m_cut = m1_cut | m2_cut;
 assign m1_sync = m1read & m1c5 & m1c4 & m1c3 & m1c2 & m1c1 & ~m1c0;
 assign m2_sync = m2read & m2c5 & m2c4 & m2c3 & m2c2 & m2c1 & ~m2c0;

 always @(m1_cut) begin
  if (m1_cut == 1'b1)
   init_cnt = 1'b0;
  else
   init_cnt = 1'b1;
 end

always @(m1_cut or m2_cut or init_cnt or cnt_reg) begin 
  if(m1_cut==1'b1)        cnt_sel = 1'b1;
  else if(m2_cut==1'b1)   cnt_sel = 1'b0;
  else if(init_cnt==1'b1) cnt_sel = 1'b0;
  else                    cnt_sel = cnt_reg;
end

 always @(posedge clkdec or negedge rstdec_x) begin
   if( !rstdec_x )
     cnt_reg <= 1'b0;
   else
     cnt_reg <= cnt_sel;
 end

 assign start_m1 = st_reg & ~cnt_reg;
 assign start_m2 = st_reg & cnt_reg;

always @(start_m1 or m1_cut or next_ready1) begin
  if(start_m1==1'b1)    nr1_sel = 1'b1;
  else if(m1_cut==1'b1) nr1_sel = 1'b0;
  else                  nr1_sel = next_ready1;
end

 always @(posedge clkdec or negedge rstdec_x) begin
   if( !rstdec_x )
     next_ready1 <= 1'b0;
   else
     next_ready1 <= nr1_sel;
 end

 always @(start_m2 or m2_cut or next_ready2) begin
   if(start_m2==1'b1)     nr2_sel = 1'b1;
   else if(m2_cut==1'b1)  nr2_sel = 1'b0;
   else                   nr2_sel = next_ready2;
 end

 always @(posedge clkdec or negedge rstdec_x) begin
   if( !rstdec_x )
     next_ready2 <= 1'b0;
   else
     next_ready2 <= nr2_sel;
 end

 always @(start_m1 or m1_sync or m1_reg) begin
   if(m1_sync==1'b1)       m1_sel = 1'b1;
   else if(start_m1==1'b1) m1_sel = 1'b0;
   else                    m1_sel = m1_reg;
 end

 always @(posedge clkdec or negedge rstdec_x) begin
   if(!rstdec_x)
     m1_reg <= 1'b1;
   else
     m1_reg <= m1_sel;
 end

 always @(start_m2 or m2_sync or m2_reg) begin
  if(m2_sync==1'b1)       m2_sel = 1'b1;
  else if(start_m2==1'b1) m2_sel = 1'b0;
  else                    m2_sel = m2_reg;
 end

 always @(posedge clkdec or negedge rstdec_x) begin
   if(!rstdec_x)
     m2_reg <= 1'b1;
   else
     m2_reg <= m2_sel;
 end

 assign m1rst = ~(start_m1 | m1_reg);
 assign m2rst = ~(start_m2 | m2_reg);

 always @(posedge clkdec) begin
  nx_reg3 <= nx_reg2;
  nx_reg2 <= nx_reg1;
  nx_reg1 <= m_cut;
 end

 assign GONEXT = nx_reg3;

 idct_xc128 idct_xc128_1(
       .rstdec_x(rstdec_x), 
       .clkdec(clkdec),
       .mrst(m1rst), 
       .ct({m1read, m1c5, m1c4, m1c3, m1c2, m1c1, m1c0})
 );

 idct_xc128 idct_xc128_2(
       .rstdec_x(rstdec_x), 
       .clkdec(clkdec), 
       .mrst(m2rst), 
       .ct({m2read, m2c5, m2c4, m2c3, m2c2, m2c1, m2c0})
 );

  idct_trnad idct_trnad_1(
       .clkdec(clkdec), 
       .CI({m1read, m1c5, m1c4, m1c3, m1c2, m1c1, m1c0}), 
       .DO(LDTM0ADD81DD)
 );

  idct_trnad idct_trnad_2(
       .clkdec(clkdec), 
       .CI({m2read, m2c5, m2c4, m2c3, m2c2, m2c1, m2c0}), 
       .DO(LDTM1ADD81DD)
 );

endmodule
