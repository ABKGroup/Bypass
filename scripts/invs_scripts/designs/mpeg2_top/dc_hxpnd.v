// ----------------------------------------------
// File: dc_hxpnd.v
// Module: dc_hxpnd
// Function:pixcel expand for horizon line
// ----------------------------------------------

module dc_hxpnd ( 
   clkdec, 
   rstdec_x, 
   d_c1_slct_r, 
   m_decdt_r, 
   d_f_ff_enb_r, 
   d_b_ff_enb_r, 
   d_pix_0, 
   d_pix_1, 
   d_pix_2, 
   d_pix_3, 
   d_pix_4, 
   d_pix_5, 
   d_pix_6, 
   d_pix_7, 
   d_pix_8, 
   d_pix_9, 
   d_pix_a, 
   d_pix_b, 
   d_pix_c, 
   d_pix_d, 
   d_pix_e, 
   d_pix_f, 
   d_decdt
);

input         clkdec;    
input         rstdec_x;  
input         d_c1_slct_r; 
input  [15:0] m_decdt_r;   
input  [7:0]  d_f_ff_enb_r;
input         d_b_ff_enb_r;
output [7:0]  d_pix_0;     
output [7:0]  d_pix_1;     
output [7:0]  d_pix_2;     
output [7:0]  d_pix_3;     
output [7:0]  d_pix_4;     
output [7:0]  d_pix_5;     
output [7:0]  d_pix_6;     
output [7:0]  d_pix_7;     
output [7:0]  d_pix_8;     
output [7:0]  d_pix_9;     
output [7:0]  d_pix_a;     
output [7:0]  d_pix_b;     
output [7:0]  d_pix_c;     
output [7:0]  d_pix_d;     
output [7:0]  d_pix_e;     
output [7:0]  d_pix_f;     
output [15:0] d_decdt;     

wire          clkdec;    
wire          rstdec_x;  
wire          d_c1_slct_r;  // conposit select
wire  [15:0]  m_decdt_r;    // pixcel data
wire   [7:0]  d_f_ff_enb_r; // front-ff enb
wire          d_b_ff_enb_r; // back-ff enb
reg    [7:0]  d_pix_0;      // pix_0
reg    [7:0]  d_pix_1;      // pix_1
reg    [7:0]  d_pix_2;      // pix_2
reg    [7:0]  d_pix_3;      // pix_3
reg    [7:0]  d_pix_4;      // pix_4
reg    [7:0]  d_pix_5;      // pix_5
reg    [7:0]  d_pix_6;      // pix_6
reg    [7:0]  d_pix_7;      // pix_7
reg    [7:0]  d_pix_8;      // pix_8
reg    [7:0]  d_pix_9;      // pix_9
reg    [7:0]  d_pix_a;      // pix_a
reg    [7:0]  d_pix_b;      // pix_b
reg    [7:0]  d_pix_c;      // pix_c
reg    [7:0]  d_pix_d;      // pix_d
reg    [7:0]  d_pix_e;      // pix_e
reg    [7:0]  d_pix_f;      // pix_f
wire  [15:0]  d_decdt;      // pixcel data
reg   [15:0]  r_m_decdt;    // pixcel data
reg   [15:0]  r_m_decdt1;   // pixcel data
reg   [15:0]  r_dly0;         // pixcel data dly
reg   [15:0]  r_dly1;         // pixcel data dly
reg   [15:0]  r_dly2;         // pixcel data dly
reg   [15:0]  r_dly3;         // pixcel data dly
reg    [7:0]  r_ff0;          // pix_0
reg    [7:0]  r_ff1;          // pix_1
reg    [7:0]  r_ff2;          // pix_2
reg    [7:0]  r_ff3;          // pix_3
reg    [7:0]  r_ff4;          // pix_4
reg    [7:0]  r_ff5;          // pix_5
reg    [7:0]  r_ff6;          // pix_6
reg    [7:0]  r_ff7;          // pix_7
reg    [7:0]  r_ff8;          // pix_8
reg    [7:0]  r_ff9;          // pix_9
reg    [7:0]  r_ffa;          // pix_a
reg    [7:0]  r_ffb;          // pix_b
reg    [7:0]  r_ffc;          // pix_c
reg    [7:0]  r_ffd;          // pix_d
reg    [7:0]  r_ffe;          // pix_e
reg    [7:0]  r_fff;          // pix_f
wire   [7:0]  w_udata;        // pixcel data(Upper)
wire   [7:0]  w_ddata;        // pixcel data(lower)

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_m_decdt1 <= 16'd0;
        r_m_decdt  <= 16'd0;
      end
    else
      begin
        r_m_decdt1 <= m_decdt_r;
        r_m_decdt  <= r_m_decdt1;
      end
  end

assign d_decdt = r_m_decdt;

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_dly3 <= 16'd0;
        r_dly2 <= 16'd0;
        r_dly1 <= 16'd0;
        r_dly0 <= 16'd0;
      end
    else
      begin
        r_dly3 <= r_dly2;
        r_dly2 <= r_dly1;
        r_dly1 <= r_dly0;
        r_dly0 <= r_m_decdt;
      end
  end

assign w_udata = (d_c1_slct_r) ? r_dly3[15:8] : r_m_decdt[15:8] ;
assign w_ddata = (d_c1_slct_r) ? r_dly3[7:0] : r_m_decdt[7:0] ;

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_ff0 <= 8'd0;
        r_ff1 <= 8'd0;
        r_ff2 <= 8'd0;
        r_ff3 <= 8'd0;
        r_ff4 <= 8'd0;
        r_ff5 <= 8'd0;
        r_ff6 <= 8'd0;
        r_ff7 <= 8'd0;
        r_ff8 <= 8'd0;
        r_ff9 <= 8'd0;
        r_ffa <= 8'd0;
        r_ffb <= 8'd0;
        r_ffc <= 8'd0;
        r_ffd <= 8'd0;
        r_ffe <= 8'd0;
        r_fff <= 8'd0;
      end
    else
      begin
        case (d_f_ff_enb_r)
          8'b00000001 :
                        begin
                          r_ff0 <= w_udata;
                          r_ff1 <= w_ddata;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b00000010 :
                        begin
                          r_ff2 <= w_udata;
                          r_ff3 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b00000100 :
                        begin
                          r_ff4 <= w_udata;
                          r_ff5 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b00001000 :
                        begin
                          r_ff6 <= w_udata;
                          r_ff7 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b00010000 :
                        begin
                          r_ff8 <= w_udata;
                          r_ff9 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b00100000 :
                        begin
                          r_ffa <= w_udata;
                          r_ffb <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b01000000 :
                        begin
                          r_ffc <= w_udata;
                          r_ffd <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
          8'b10000000 :
                        begin
                          r_ffe <= w_udata;
                          r_fff <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                        end
          default :    
                        begin
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                          r_ff8 <= r_ff8;
                          r_ff9 <= r_ff9;
                          r_ffa <= r_ffa;
                          r_ffb <= r_ffb;
                          r_ffc <= r_ffc;
                          r_ffd <= r_ffd;
                          r_ffe <= r_ffe;
                          r_fff <= r_fff;
                        end
        endcase
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        d_pix_0 <= 8'd0;
        d_pix_1 <= 8'd0;
        d_pix_2 <= 8'd0;
        d_pix_3 <= 8'd0;
        d_pix_4 <= 8'd0;
        d_pix_5 <= 8'd0;
        d_pix_6 <= 8'd0;
        d_pix_7 <= 8'd0;
        d_pix_8 <= 8'd0;
        d_pix_9 <= 8'd0;
        d_pix_a <= 8'd0;
        d_pix_b <= 8'd0;
        d_pix_c <= 8'd0;
        d_pix_d <= 8'd0;
        d_pix_e <= 8'd0;
        d_pix_f <= 8'd0;
      end
    else if (d_b_ff_enb_r == 1'b1)
      begin
        d_pix_0 <= r_ff0;
        d_pix_1 <= r_ff1;
        d_pix_2 <= r_ff2;
        d_pix_3 <= r_ff3;
        d_pix_4 <= r_ff4;
        d_pix_5 <= r_ff5;
        d_pix_6 <= r_ff6;
        d_pix_7 <= r_ff7;
        d_pix_8 <= r_ff8;
        d_pix_9 <= r_ff9;
        d_pix_a <= r_ffa;
        d_pix_b <= r_ffb;
        d_pix_c <= r_ffc;
        d_pix_d <= r_ffd;
        d_pix_e <= r_ffe;
        d_pix_f <= r_fff;
      end
  end

endmodule

