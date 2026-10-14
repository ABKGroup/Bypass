// ----------------------------------------------
// File: buswtop.v
// Module: buswtop
// Function:BusI/F(W) write top
// ----------------------------------------------

module buswtop(
                   clkdec,   
                   rstdec_x, 
                   g_field_start_add_r,
                   g_field_offset_r,   
                   g_cbcr_offset_r,    
                   g_line_offset_r,    
                   b_request_r,        
                   b_field_num_r,      
                   b_addressx_r,       
                   b_addressy_r,       
                   b_byte_num_r,       
                   b_line_num_r,       
                   b_write_enable_r,   
                   b_write_data,      
                   ph_vh_2_gnt,       
                   vwh_acceptance_r,  
                   vwh_data_wait,     
                   vh_2_ph_req,           
                   vh_2_ph_add,           
                   vh_2_ph_data          
                   );
    
    parameter     P_F_OFFSET = 'd11;         // field offset signals width

    input                clkdec;            
    input                rstdec_x;          
    input [31:10]        g_field_start_add_r;
    input [P_F_OFFSET:0] g_field_offset_r;    // field size offset (byte)
    input [P_F_OFFSET:0] g_cbcr_offset_r;     // CbCr size offset (byte)
    input                g_line_offset_r;     // line offset
    input                b_request_r;         // block request (from BDC)
    input [3:0]          b_field_num_r;       // field number
    input [7:0]          b_addressx_r;        // X-axis address (X/8 in field)
    input [8:0]          b_addressy_r;        // Y-axis address (Y/2 in field)
    input [1:0]          b_byte_num_r;        // byte number (in line)
    input [2:0]          b_line_num_r;        // line number (in block)
    input                b_write_enable_r;    // write_data enable (from BDC)
    input [63:0]         b_write_data;        // write_data (from BDC)
    input                ph_vh_2_gnt;         // SHwy grant

    output               vwh_acceptance_r;    // request acceptance signals
    output               vwh_data_wait;       // wait write_data (to BDC)
    output               vh_2_ph_req;         // SHwy request
    output [31:0]        vh_2_ph_add;         // SHwy address
    output [31:0]        vh_2_ph_data;        // SHwy data

    
    wire                 clkdec;         
    wire                 rstdec_x;       
    wire [31:10]         g_field_start_add_r; // field0 address
    wire [P_F_OFFSET:0]  g_field_offset_r;    // field size offset (byte)
    wire [P_F_OFFSET:0]  g_cbcr_offset_r;     // CbCr size offset (byte)
    wire                 g_line_offset_r;     // line offset
    wire                 vwh_acceptance_r;    // request acceptance signals
    wire                 b_request_r;         // block request (from BDC)
    wire [3:0]           b_field_num_r;       // field number
    wire [7:0]           b_addressx_r;        // X-axis address (X/8 in field)
    wire [8:0]           b_addressy_r;        // Y-axis address (Y/2 in field)
    wire [1:0]           b_byte_num_r;        // byte number (in line)
    wire [2:0]           b_line_num_r;        // line number (in block)
    wire                 vwh_data_wait;       // wait write_data (to BDC)
    wire                 b_write_enable_r;    // write_data enable (from BDC)
    wire [63:0]          b_write_data;        // write_data (from BDC)
    wire                 vh_2_ph_req;         // SHwy request
    wire                 ph_vh_2_gnt;         // SHwy grant
    wire [31:0]          vh_2_ph_add;         // SHwy address
    wire                 vwh_wdc_dataready;
    wire                 vwh_wrq_tranacc;


    b_wreq b_wreq(
         .clkdec(clkdec),           
         .rstdec_x(rstdec_x),       
         .g_field_start_add_r(g_field_start_add_r),
         .g_field_offset_r(g_field_offset_r), 
         .g_cbcr_offset_r(g_cbcr_offset_r),   
         .g_line_offset_r(g_line_offset_r),   
         .b_request_r(b_request_r),     
         .b_field_num_r(b_field_num_r), 
         .b_addressx_r(b_addressx_r),   
         .b_addressy_r(b_addressy_r),   
         .b_byte_num_r(b_byte_num_r),   
         .b_line_num_r(b_line_num_r),   
         .ph_vh_2_gnt(ph_vh_2_gnt),       
         .vwh_wdc_dataready(vwh_wdc_dataready),
         .b_write_enable_r(b_write_enable_r), 
         .vwh_acceptance_r(vwh_acceptance_r), 
         .vh_2_ph_req(vh_2_ph_req),         
         .vh_2_ph_add(vh_2_ph_add),         
         .vwh_wrq_tranacc(vwh_wrq_tranacc)
   );

    b_wdcl b_wdcl(
         .clkdec(clkdec),           
         .rstdec_x(rstdec_x),       
         .b_write_enable_r(b_write_enable_r), 
         .b_write_data(b_write_data), 
         .vwh_wrq_tranacc(vwh_wrq_tranacc),
         .vwh_data_wait(vwh_data_wait),      
         .vh_2_ph_data(vh_2_ph_data),        
         .vwh_wdc_dataready(vwh_wdc_dataready)  
   );

endmodule





