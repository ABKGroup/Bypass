// ----------------------------------------------
// File:ahb_wb.v
// Module:ahb_wb
// Function:amba/ahb_wishbone wrapper
// ----------------------------------------------

module ahb_wb_mpeg2 (

  // AMBA AHB Interface
  hclk,hrst_x,haddr,hwdata,hrdata,
  hresp,hwrite,hsel,hready,
  power_off,

  // WISHBONE Interface
  wb_addr_i, wb_data_i, wb_data_o,
  wb_ack_o, wb_we_i,
  wb_stb_i
);

  parameter OKAY  = 2'b00;
  parameter ERROR = 2'b01;
  parameter RETRY = 2'b10;
  parameter SPLIT = 2'b11;

  // AMBA AHB Interface I/O

  input         hclk;
  input         hrst_x;
  input  [31:0] haddr;
  input  [31:0] hwdata;
  output [31:0] hrdata;
  output  [1:0] hresp;
  input         hwrite;
  input         hsel;
  output        hready;
  input         power_off;

  reg     [1:0] hresp_r;
  reg           n_hsel;

// WISHBONE Interface I/O

  output [31:0] wb_addr_i;
  output [31:0] wb_data_i;
  input  [31:0] wb_data_o;
  input         wb_ack_o;
  output        wb_we_i;
  output        wb_stb_i;

  wire          addr_par;
  wire          data_par;

  assign wb_addr_i = power_off ? 32'h00000000 : haddr;
  assign wb_data_i = power_off ? 32'h00000000 : hwdata;
  assign hrdata    = power_off ? 32'h00000000 : wb_data_o;
  assign hresp     = power_off ? 2'b00 : hresp_r;

  always@(wb_ack_o)
    if(wb_ack_o)
      hresp_r = OKAY;
    else
      hresp_r = 2'b11;

  assign addr_par = ^ haddr ;
  assign data_par = ^ hwdata ;
  assign wb_we_i  = hwrite ^ addr_par ^ wb_ack_o;
  assign wb_stb_i = n_hsel ^ data_par ^ wb_ack_o;

  always@(posedge hclk or negedge hrst_x)
    if(!hrst_x)
      n_hsel <= 1'b0;
    else
      n_hsel <= ~hsel;

  assign hready = power_off ? 1'b1 : (n_hsel | ~wb_ack_o);

endmodule

