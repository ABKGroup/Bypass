// ----------------------------------------------
// File: busrtop.v
// Module: busrtop
// Function:BusI/F(R) read top
// ----------------------------------------------

module busrtop(
        clkdec
        ,rstdec_x
        ,g_field_start_add_r
        ,g_field_offset_r
        ,g_cbcr_offset_r
        ,g_line_offset_r
        ,f_field_num_r
        ,f_addressx_r
        ,f_addressy_r
        ,f_request_r
        ,f_byte_num_r
        ,f_line_num_r
        ,ph_vh_1_gnt
        ,ph_vh_1_r_data
        ,ph_vh_1_r_enable
        ,vrh_acceptance_r
        ,vh_1_ph_req
        ,vh_1_ph_add
        ,vrh_read_data_r

);

input           clkdec;
input           rstdec_x;
input [31:10]   g_field_start_add_r; // field0 address
input [11:0]    g_field_offset_r;    // field size offset (byte)
input [11:0]    g_cbcr_offset_r;     // CbCr size offset (byte)
input           g_line_offset_r;     // line offset
input [3:0]     f_field_num_r;       // field number
input [10:0]    f_addressx_r;        // X-axis address (X/8 in field)
input [9:0]     f_addressy_r;        // Y-axis address (Y/2 in field)
input           f_request_r;         // block request (from BUC)
input [1:0]     f_byte_num_r;        // byte number (in line)
input [2:0]     f_line_num_r;        // line number (in block)

input           ph_vh_1_gnt;         // SHwy grant
input [31:0]    ph_vh_1_r_data;      // SHwy response data
input           ph_vh_1_r_enable;

output          vrh_acceptance_r;    // request acceptance
output          vh_1_ph_req;         // SHwy request
output  [31:0]  vh_1_ph_add;         // CPU address
output  [63:0]  vrh_read_data_r;     // read data

wire            vrh_line_enable;     // sub module line enable information
wire    [3:0]   vrh_line_type;       // sub module line type information
wire            vrh_que_full_r;      // sub module que full information


b_rreq b_rreq(
        .clkdec(clkdec),
        .rstdec_x(rstdec_x),
        .g_field_start_add_r(g_field_start_add_r),
        .g_field_offset_r(g_field_offset_r),
        .g_cbcr_offset_r(g_cbcr_offset_r),
        .g_line_offset_r(g_line_offset_r),
        .f_field_num_r2(f_field_num_r),
        .f_addressx_r2(f_addressx_r),
        .f_addressy_r2(f_addressy_r),
        .f_request_r2(f_request_r),
        .f_byte_num_r2(f_byte_num_r),
        .f_line_num_r2(f_line_num_r),
        .vrh_que_full_r(vrh_que_full_r),
        .vh_1_ph_req(vh_1_ph_req),
        .ph_vh_1_gnt(ph_vh_1_gnt),
        .vrh_acceptance_rd(vrh_acceptance_r),
        .vrh_line_enable(vrh_line_enable),
        .vrh_line_type(vrh_line_type),
        .vh_1_ph_add(vh_1_ph_add)
);

b_rres b_rres(
  .clkdec(clkdec),
  .rstdec_x(rstdec_x),
  .vrh_line_type(vrh_line_type),
  .ph_vh_1_r_enable(ph_vh_1_r_enable),
  .ph_vh_1_r_data(ph_vh_1_r_data),
  .vrh_line_enable(vrh_line_enable),
  .vrh_que_full_r(vrh_que_full_r),
  .vrh_read_data_rd(vrh_read_data_r)
);

endmodule


