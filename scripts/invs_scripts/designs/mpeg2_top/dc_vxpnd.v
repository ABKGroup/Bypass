// ----------------------------------------------
// File: dc_vxpnd.v
// Module: dc_vxpnd
// Function: pixcel expand for horizon line
// ----------------------------------------------

module dc_vxpnd ( 
   clkdec, 
   rstdec_x, 
   d_c_slct, 
   d_vflt_din, 
   d_f_ff_enb_r, 
   d_b_ff_enb_r, 
   d_pix_0, 
   d_pix_1, 
   d_pix_2, 
   d_pix_3, 
   d_pix_4, 
   d_pix_5, 
   d_pix_6, 
   d_pix_7
);

input        clkdec;       // clk
input        rstdec_x;     // reset
input        d_c_slct;     // composit select
input  [7:0] d_vflt_din;   // data in
input  [7:0] d_f_ff_enb_r; // front-ff enb
input        d_b_ff_enb_r; // back-ff enb
output [7:0] d_pix_0;      // pix_0
output [7:0] d_pix_1;      // pix_1
output [7:0] d_pix_2;      // pix_2
output [7:0] d_pix_3;      // pix_3
output [7:0] d_pix_4;      // pix_4
output [7:0] d_pix_5;      // pix_5
output [7:0] d_pix_6;      // pix_6
output [7:0] d_pix_7;      // pix_7

wire         clkdec;       // clk
wire         rstdec_x;     // reset
wire         d_c_slct;     // composit select
wire   [7:0] d_vflt_din;   // data in
wire   [7:0] d_f_ff_enb_r; // front-ff enb
wire         d_b_ff_enb_r; // back-ff enb
wire   [7:0] w_ddata;      // selected data
reg    [7:0] d_pix_0;      // pix_0
reg    [7:0] d_pix_1;      // pix_1
reg    [7:0] d_pix_2;      // pix_2
reg    [7:0] d_pix_3;      // pix_3
reg    [7:0] d_pix_4;      // pix_4
reg    [7:0] d_pix_5;      // pix_5
reg    [7:0] d_pix_6;      // pix_6
reg    [7:0] d_pix_7;      // pix_7
reg    [7:0] rrvflt_din;     // data in
reg    [7:0] rvflt_din;      // data in
reg    [7:0] r_dly0;         // data dly
reg    [7:0] r_dly1;         // data dly
reg    [7:0] r_dly2;         // data dly
reg    [7:0] r_dly3;         // data dly
reg    [7:0] r_ff0;          // front-ff0
reg    [7:0] r_ff1;          // front-ff1
reg    [7:0] r_ff2;          // front-ff2
reg    [7:0] r_ff3;          // front-ff3
reg    [7:0] r_ff4;          // front-ff4
reg    [7:0] r_ff5;          // front-ff5
reg    [7:0] r_ff6;          // front-ff6
reg    [7:0] r_ff7;          // front-ff7

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        rrvflt_din <= 8'd0;
      end
    else
      begin
        rrvflt_din <= d_vflt_din;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        rvflt_din <= 8'd0;
      end
    else
      begin
        rvflt_din <= rrvflt_din;
      end
  end

always @(posedge clkdec or negedge rstdec_x) 
  begin
    if (!rstdec_x)
      begin
        r_dly3 <= 8'd0;
        r_dly2 <= 8'd0;
        r_dly1 <= 8'd0;
        r_dly0 <= 8'd0;
      end
    else
      begin
        r_dly3 <= r_dly2;
        r_dly2 <= r_dly1;
        r_dly1 <= r_dly0;
        r_dly0 <= rvflt_din;
      end
  end

assign w_ddata = (d_c_slct) ? r_dly3 : rvflt_din ;

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
      end
    else
      begin
        case (d_f_ff_enb_r)
          8'b00000001 :
                        begin
                          r_ff0 <= w_ddata;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                        end
          8'b00000010 :
                        begin
                          r_ff1 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                        end
          8'b00000100 :
                        begin
                          r_ff2 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                        end
          8'b00001000 :
                        begin
                          r_ff3 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                        end
          8'b00010000 :
                        begin
                          r_ff4 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                        end
          8'b00100000 :
                        begin
                          r_ff5 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
                        end
          8'b01000000 :
                        begin
                          r_ff6 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff7 <= r_ff7;
                        end
          8'b10000000 :
                        begin
                          r_ff7 <= w_ddata;
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                        end
          default     :
                        begin
                          r_ff0 <= r_ff0;
                          r_ff1 <= r_ff1;
                          r_ff2 <= r_ff2;
                          r_ff3 <= r_ff3;
                          r_ff4 <= r_ff4;
                          r_ff5 <= r_ff5;
                          r_ff6 <= r_ff6;
                          r_ff7 <= r_ff7;
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
      end
  end

endmodule

