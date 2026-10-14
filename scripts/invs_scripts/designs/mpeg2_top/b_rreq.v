// ----------------------------------------------
// File: b_rreq.v
// Module: b_rreq
// Function:BusI/F(R) bus request controller
// ----------------------------------------------
// History:
// Version Date          Author    Description
// v1.0    9.June.2004   hdlab     Original
// ----------------------------------------------
// Modification History:
// $Log: b_rreq.v,v $
// Revision 1.4  2004/09/21 07:46:08  sabato
// *** empty log message ***
//
// Revision 1.3  2004/09/16 02:21:28  sabato
// modify rtq
//
// Revision 1.2  2004/09/14 11:34:41  sabato
// modify for scan
//
// Revision 1.1.1.1  2004/06/10 11:06:08  sabato
// imported : initial version
//
//

module b_rreq (
        clkdec
        ,rstdec_x
        ,g_field_start_add_r
        ,g_field_offset_r
        ,g_cbcr_offset_r
        ,g_line_offset_r
        ,f_field_num_r2
        ,f_addressx_r2
        ,f_addressy_r2
        ,f_byte_num_r2
        ,f_line_num_r2
        ,f_request_r2
        ,vrh_que_full_r
        ,ph_vh_1_gnt
        ,vrh_acceptance_rd
        ,vh_1_ph_req
        ,vh_1_ph_add
        ,vrh_line_enable
        ,vrh_line_type
);

parameter            P_LOAD08= 8'b00110001;// LOAD08 fix
parameter            P_LOAD16= 8'b00110001;// LOAD08 fix
parameter            P_LOAD18= 8'b00110001;// LOAD08 fix

parameter            P_F_OFFSET = 'd11;
parameter            P_F_NUM_WH = 3;
parameter            P_X_WIDTHX = 'd11;
parameter            P_Y_WIDTHX = 'd10;
parameter            P_F_MSBALI = 'd26;
parameter            P_F_LSBALI = 'd10;

input                 clkdec;     
input                 rstdec_x;   

                                            
input [31:10]         g_field_start_add_r;
input [P_F_OFFSET:0]  g_field_offset_r;
input [P_F_OFFSET:0]  g_cbcr_offset_r; 
input                 g_line_offset_r; 
input [3:0]           f_field_num_r2; 
input [10:0]          f_addressx_r2;  
input [9:0]           f_addressy_r2;  
input [1:0]           f_byte_num_r2;  
input [2:0]           f_line_num_r2;  
input                 f_request_r2;   
input                 vrh_que_full_r;  
input                 ph_vh_1_gnt;     
output                vrh_acceptance_rd;  
output                vh_1_ph_req;       
output  [31:0]        vh_1_ph_add;       
output                vrh_line_enable;
output  [3:0]         vrh_line_type;  


reg              vrh_que_full_1_r;      // que full information
reg     [26:0]   vrh_add0_r;            // que 2 for address
reg     [26:0]   vrh_add1_r;            // que 2 for address
reg              vrh_end_blk_chan_r;    // vrh_end_block F/F 
reg     [1:0]    vrh_byte0_r;           // que 2 for byte
reg     [1:0]    vrh_byte1_r;           // que 2 for byte
reg     [1:0]    vrh_byte_r;            // the last byte
reg     [2:0]    vrh_line0_r;           // que 2 for line
reg     [2:0]    vrh_line1_r;           // que 2 for line
reg     [2:0]    vrh_line_r;            // the last line
reg     [2:0]    vrh_type0_r;           // que 2 for line_type
reg     [2:0]    vrh_type1_r;           // que 2 for line_type
reg     [2:0]    vrh_type_r;            // the last line_type

reg     [1:0]    vrh_cnt_18byte_r;      // 18byte counter
reg     [1:0]    vrh_cnt_16byte_r;      // 16byte counter
reg     [3:0]    vrh_cnt_line_r;        // line counter
reg     [2:0]    vrh_lck_168_r;         // 16 18 lock signal common
reg              vrh_requ_blk_r;        // request change signal
reg              vrh_line_enable16_r;   // 16byte line_enable
reg              vrh_line_enable18_r;   // 18byte line_enable
reg              vrh_que2_flag1_r;      // que 2 flag
reg              vrh_que2_flag2_r;      // que 2 flag
reg              vrh_request_r;         // f_request_r F/F  
reg  [1:0]       vrh_rrq_bytenum_r;     // byte numer  
reg  [2:0]       vrh_rrq_linenum_r;     // line numer  
reg              vrh_accep_r;           // request acceptance inside
 
                                        // request block signals
reg              vrh_acceptance_r;      // request acceptance signals
reg              vrh_acceptance_rd;     // request acceptance signals
reg  [10:0]      vrh_rrq_addx_r;        // X-axis address (X/8 in field)
reg     [9:0]    vrh_rrq_addy_r;        // Y-axis address (Y/2 in field)
reg     [3:0]    vrh_rrq_fldnum_r;      // f_field_num_r  F/F

                                        // SHwy Request signals
reg              vh_1_ph_req;           // SHwy request
reg   [31:0]     vh_1_ph_add;           // SHwy address

reg   [3:0]      f_field_num_r1; 
reg   [10:0]     f_addressx_r1;  
reg   [9:0]      f_addressy_r1;  
reg   [1:0]      f_byte_num_r1;  
reg   [2:0]      f_line_num_r1;  
reg              f_request_r1;   
reg   [3:0]      f_field_num_r; 
reg   [10:0]     f_addressx_r;  
reg   [9:0]      f_addressy_r;  
reg   [1:0]      f_byte_num_r;  
reg   [2:0]      f_line_num_r;  
reg              f_request_r;   

//initial field top address
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld1_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld2_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld3_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld4_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld5_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld6_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld7_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld8_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld9_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld10_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld11_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld12_r;
reg [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld13_r;

               //initial block top address
reg [31:10]             vrh_rrq_fldstatadd_r;
reg [P_F_OFFSET:0]      vrh_rrq_fldoft_r;
reg [P_F_OFFSET:0]      vrh_rrq_cbcroft_r;
reg                     vrh_rrq_lineoft_r;


wire               vrh_que_release;     // que full information
wire               vrh_end_block;       // Y or C end
wire               vrh_end_block_sig;   // Y or C end selcter output
wire               vrh_cnt_enable;      // enable for line counter 
wire               vrh_gnt_req;         // gnt && req 
wire    [26:0]     vrh_add_que_out;     // address que out
wire    [1:0]      vrh_byte_que_out;    // byte que out
wire    [2:0]      vrh_line_que_out;    // line que out
wire    [2:0]      vrh_type_que_out;    // line_type que out
wire    [7:0]      vrh_opc_18byte;      // 8byte X 3 (18byte) opcode
wire    [7:0]      vrh_opc_16byte;      // 8byte X 2 (16byte) opcode
wire    [7:0]      vrh_opc_out;         // opcode selcter out
wire               vrh_16byte_end;      // 16byte end
wire               vrh_18byte_end;      // 18byte end
wire               vrh_line_finish;     // the last line
wire               vrh_byte_chan;       // byte change
wire    [26:0]     vrh_add0_sig;        // que 2 address selctor out
wire    [26:0]     vrh_add1_sig;        // que 2 address selctor out
wire    [1:0]      vrh_byte0_sig;       // que 2 byte selctor out
wire    [1:0]      vrh_byte1_sig;       // que 2 byte selctor out
wire    [2:0]      vrh_line0_sig;       // que 2 line selctor out
wire    [2:0]      vrh_line1_sig;       // que 2 line selctor out
wire    [2:0]      vrh_type0_sig;       // que 2 line_type selctor out
wire    [2:0]      vrh_type1_sig;       // que 2 line_type selctor out
wire               vrh_8_lck;           // 16/18byte for 8byte lock
wire               vrh_16_lck;          // 16byte lock
wire               vrh_18_lck;          // 18byte lock
wire               vrh_18_lck_norm;     // 18byte lock signal normal selctor out
wire               vrh_16_lck_norm;     // 16byte lock signal normal selctor out
wire               vrh_excep_sig;       // 16byte/18byte(lock or opcode or line_enable) signal exception 
wire               vrh_lck;             // 8/16/18byte lock selctor out
wire    [3:0]      vrh_line_case;       // input line case
wire               vrh_que2_flag_full;  // gue 2 full
wire               vrh_que2_flag_emp;   // gue 2 empty
wire               vrh_que2_flag_whi;   // gue 2 which
wire               vrh_accep_request;   // acceptance && request
wire               vrh_line59_lck;      // line 5&9 lock
wire               vrh_line_chan;       // line change y_address
wire               vrh_req_sig;         // req back signal
wire               vrh_req_and;         // vrh_req_sig & vh_1_ph_req


                                             //initial field top address
wire [P_F_OFFSET+1:0]   vrh_rrq_fldoft2;
wire [P_F_OFFSET+2:0]   vrh_rrq_fldoft3;
wire [P_F_OFFSET+2:0]   vrh_rrq_fldoft4;
wire [P_F_OFFSET+3:0]   vrh_rrq_fldoft5;
wire [P_F_OFFSET+3:0]   vrh_rrq_fldoft6;
wire [P_F_OFFSET+3:0]   vrh_rrq_fldoft7;
wire [P_F_OFFSET+3:0]   vrh_rrq_fldoft8;
wire [P_F_OFFSET+4:0]   vrh_rrq_fldoft9;
wire [P_F_OFFSET+4:0]   vrh_rrq_fldoft10;
wire [P_F_OFFSET+4:0]   vrh_rrq_fldoft11;
wire [P_F_OFFSET+4:0]   vrh_rrq_fldoft12;
wire [P_F_OFFSET+4:0]   vrh_rrq_fldoft13;

                                        
wire [26:0]                  vrh_rrq_add;
wire [2:0]                   vrh_rrq_aline1kadd;
wire [P_F_MSBALI:P_F_LSBALI] vrh_rrq_selycbcradd;
wire [P_Y_WIDTHX + 1:0]      vrh_rrq_iniyaddsft;
wire [P_F_MSBALI:P_F_LSBALI] vrh_rrq_curcbcradd;
wire [P_F_MSBALI:P_F_LSBALI] vrh_rrq_selfldadd;


    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vrh_rrq_fldstatadd_r <= 22'h000000;
            vrh_rrq_fldoft_r     <= 12'h000;
            vrh_rrq_cbcroft_r    <= 12'h000;
            vrh_rrq_lineoft_r    <= 1'b0;
        end else begin
            vrh_rrq_fldstatadd_r <= g_field_start_add_r + vrh_rrq_fldstatadd_r - 1;
            vrh_rrq_fldoft_r     <= g_field_offset_r;
            vrh_rrq_cbcroft_r    <= g_cbcr_offset_r;
            vrh_rrq_lineoft_r    <= g_line_offset_r;
        end
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vrh_rrq_addx_r[P_X_WIDTHX-1:0] <= 8'h00;
            vrh_rrq_addy_r[P_Y_WIDTHX-1:0] <= 9'h00;
            vrh_rrq_fldnum_r[3:0]  <= 4'b0000;
            vrh_rrq_bytenum_r[1:0] <= 2'b00;
            vrh_rrq_linenum_r[2:0] <= 3'b000;
        end else begin
            vrh_rrq_addx_r[P_X_WIDTHX-1:0] <= f_addressx_r[P_X_WIDTHX-1:0];
            vrh_rrq_addy_r[P_Y_WIDTHX-1:0] <= f_addressy_r[P_Y_WIDTHX-1:0];
            vrh_rrq_fldnum_r[3:0]  <= f_field_num_r[3:0];
            vrh_rrq_bytenum_r[1:0] <= f_byte_num_r[1:0];
            vrh_rrq_linenum_r[2:0] <= f_line_num_r[2:0];
        end
    end


assign vrh_rrq_fldoft2 = vrh_rrq_fldoft_r << 1;
assign vrh_rrq_fldoft4 = vrh_rrq_fldoft_r << 2;
assign vrh_rrq_fldoft8 = vrh_rrq_fldoft_r << 3;

assign vrh_rrq_fldoft6  = vrh_rrq_fldoft2 + vrh_rrq_fldoft4;
assign vrh_rrq_fldoft7  = vrh_rrq_fldoft3 + vrh_rrq_fldoft4;
assign vrh_rrq_fldoft9  = vrh_rrq_fldoft_r + vrh_rrq_fldoft8;
assign vrh_rrq_fldoft10 = vrh_rrq_fldoft2 + vrh_rrq_fldoft8;
assign vrh_rrq_fldoft11 = vrh_rrq_fldoft3 + vrh_rrq_fldoft8;
assign vrh_rrq_fldoft12 = vrh_rrq_fldoft4 + vrh_rrq_fldoft8;
assign vrh_rrq_fldoft13 = vrh_rrq_fldoft5 + vrh_rrq_fldoft8;

assign vrh_rrq_fldoft3  = vrh_rrq_fldoft_r + vrh_rrq_fldoft2;
assign vrh_rrq_fldoft5  = vrh_rrq_fldoft_r + vrh_rrq_fldoft4;

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vrh_rrq_fld1_r  <= 17'h00000;
            vrh_rrq_fld2_r  <= 17'h00000;
            vrh_rrq_fld3_r  <= 17'h00000;
            vrh_rrq_fld4_r  <= 17'h00000;
            vrh_rrq_fld5_r  <= 17'h00000;
            vrh_rrq_fld6_r  <= 17'h00000;
            vrh_rrq_fld7_r  <= 17'h00000;
            vrh_rrq_fld8_r  <= 17'h00000;
            vrh_rrq_fld9_r  <= 17'h00000;
            vrh_rrq_fld10_r <= 17'h00000;
            vrh_rrq_fld11_r <= 17'h00000;
            vrh_rrq_fld12_r <= 17'h00000;
            vrh_rrq_fld13_r <= 17'h00000;
        end else begin
            vrh_rrq_fld1_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft_r;
            vrh_rrq_fld2_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft2;
            vrh_rrq_fld3_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft3;
            vrh_rrq_fld4_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft4;
            vrh_rrq_fld5_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft5;
            vrh_rrq_fld6_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft6;
            vrh_rrq_fld7_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft7;
            vrh_rrq_fld8_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft8;
            vrh_rrq_fld9_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft9;
            vrh_rrq_fld10_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft10;
            vrh_rrq_fld11_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft11;
            vrh_rrq_fld12_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft12;
            vrh_rrq_fld13_r <= vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vrh_rrq_fldoft13;
        end
    end


    assign vrh_rrq_add[P_F_MSBALI:P_F_LSBALI] = vrh_rrq_iniyaddsft + 
                                              {vrh_rrq_selycbcradd[P_F_MSBALI:P_F_LSBALI+3],vrh_rrq_aline1kadd};

    assign vrh_rrq_add[P_F_LSBALI-1:0] = vrh_rrq_addx_r[P_X_WIDTHX-2:0];

    assign vrh_rrq_aline1kadd = vrh_rrq_addx_r[P_X_WIDTHX-1] + vrh_rrq_selycbcradd[P_F_LSBALI+2:P_F_LSBALI];

    assign vrh_rrq_curcbcradd = vrh_rrq_cbcroft_r + vrh_rrq_selfldadd;

    assign vrh_rrq_selycbcradd = (vrh_requ_blk_r)? vrh_rrq_curcbcradd : vrh_rrq_selfldadd;

    assign vrh_rrq_iniyaddsft = vrh_rrq_addy_r << vrh_rrq_lineoft_r;

    assign vrh_rrq_selfldadd = vrh_rrq_selfld(vrh_rrq_fldnum_r,
                                               vrh_rrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI],
                                               vrh_rrq_fld1_r,
                                               vrh_rrq_fld2_r,
                                               vrh_rrq_fld3_r,
                                               vrh_rrq_fld4_r,
                                               vrh_rrq_fld5_r,
                                               vrh_rrq_fld6_r,
                                               vrh_rrq_fld7_r,
                                               vrh_rrq_fld8_r,
                                               vrh_rrq_fld9_r,
                                               vrh_rrq_fld10_r,
                                               vrh_rrq_fld11_r,
                                               vrh_rrq_fld12_r,
                                               vrh_rrq_fld13_r);
    function [26:10] vrh_rrq_selfld;
        input [P_F_NUM_WH:0] vrh_rrq_fldnum_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fldstatadd_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld1_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld2_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld3_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld4_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld5_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld6_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld7_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld8_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld9_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld10_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld11_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld12_r;
        input [P_F_MSBALI:P_F_LSBALI] vrh_rrq_fld13_r;
        begin
            case(vrh_rrq_fldnum_r)
                4'b0000: vrh_rrq_selfld = vrh_rrq_fldstatadd_r;
                4'b0001: vrh_rrq_selfld = vrh_rrq_fld1_r;
                4'b0010: vrh_rrq_selfld = vrh_rrq_fld2_r;
                4'b0011: vrh_rrq_selfld = vrh_rrq_fld3_r;
                4'b0100: vrh_rrq_selfld = vrh_rrq_fld4_r;
                4'b0101: vrh_rrq_selfld = vrh_rrq_fld5_r;
                4'b0110: vrh_rrq_selfld = vrh_rrq_fld6_r;
                4'b0111: vrh_rrq_selfld = vrh_rrq_fld7_r;
                4'b1000: vrh_rrq_selfld = vrh_rrq_fld8_r;
                4'b1001: vrh_rrq_selfld = vrh_rrq_fld9_r;
                4'b1010: vrh_rrq_selfld = vrh_rrq_fld10_r;
                4'b1011: vrh_rrq_selfld = vrh_rrq_fld11_r;
                4'b1100: vrh_rrq_selfld = vrh_rrq_fld12_r;
                4'b1101: vrh_rrq_selfld = vrh_rrq_fld13_r;
                default: vrh_rrq_selfld = 17'h00000;
            endcase
        end
    endfunction

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_field_num_r1 <= 4'h0;
  else
         f_field_num_r1 <= f_field_num_r2;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_addressx_r1  <= 11'h000;
  else
         f_addressx_r1  <= f_addressx_r2;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_addressy_r1  <= 10'h000;
  else
         f_addressy_r1  <= f_addressy_r2;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_byte_num_r1  <= 2'h0;
  else
         f_byte_num_r1  <= f_byte_num_r2;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_line_num_r1  <= 3'h0;
  else
         f_line_num_r1  <= f_line_num_r2;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_request_r1   <= 0;
  else
         f_request_r1   <= f_request_r2;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_field_num_r <= 4'h0;
  else
         f_field_num_r  <= f_field_num_r1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_addressx_r  <= 11'h000;
  else
         f_addressx_r   <= f_addressx_r1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_addressy_r  <= 10'h000;
  else
         f_addressy_r   <= f_addressy_r1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_byte_num_r  <= 2'h0;
  else
         f_byte_num_r   <= f_byte_num_r1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_line_num_r  <= 3'h0;
  else
         f_line_num_r   <= f_line_num_r1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
         f_request_r   <= 0;
  else
         f_request_r    <= f_request_r1;
end


//que full information F/F
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que_full_1_r <= 1'b0;
        else
                 vrh_que_full_1_r <= vrh_que_full_r;
 end

assign vrh_que_release = (vrh_que_full_1_r==1'b1)&(vrh_que_full_r==1'b0);

//block finish change for que 2
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_end_blk_chan_r <= 1'b0;
  else
     vrh_end_blk_chan_r <= vrh_end_block_sig;
 end

assign vrh_end_block_sig = (vrh_end_block==1'b1) ? ~vrh_end_blk_chan_r: vrh_end_blk_chan_r;

//address input
//------------ 1st block in -------------------
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_add0_r <= 27'd0;
        else
                vrh_add0_r <= vrh_add0_sig;
 end

assign vrh_add0_sig = ((vrh_requ_blk_r == 1'b0)&&(vrh_request_r==1'b1))? vrh_rrq_add: vrh_add0_r - 1'b1 ;

//------------ 2nd block in -------------------
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_add1_r <= 27'd0;
        else
                vrh_add1_r <=  vrh_add1_sig;
 end

assign  vrh_add1_sig = ((vrh_requ_blk_r == 1'b1)&&(vrh_request_r==1'b1))? vrh_rrq_add: vrh_add1_r - 1'b1;
//------------ 1st or 2nd que change -------------------

assign vrh_add_que_out = (vrh_end_block_sig == 1'b0)? vrh_add0_r : vrh_add1_r;

//byte input
//------------ 1st block in -------------------
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_byte0_r <= 2'b00;
        else
                vrh_byte0_r <= vrh_byte0_sig;
 end

assign vrh_byte0_sig = ((vrh_requ_blk_r == 1'b0)&&(vrh_request_r==1'b1))? vrh_rrq_bytenum_r: vrh_byte0_r;

//------------ 2nd block in -------------------
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_byte1_r <= 2'b00;
        else
                vrh_byte1_r <= vrh_byte1_sig;
 end

assign vrh_byte1_sig = ((vrh_requ_blk_r == 1'b1)&&(vrh_request_r==1'b1))? vrh_rrq_bytenum_r: vrh_byte1_r;

//------------ 1st or 2nd que change -------------------

assign vrh_byte_que_out = (vrh_end_block_sig == 1'b0)? vrh_byte0_r : vrh_byte1_r;

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_byte_r <= 2'b00;
        else if (vrh_end_block==1'b1)
                vrh_byte_r <= vrh_byte_que_out;
        else if (vrh_que2_flag_emp)
                vrh_byte_r <= vrh_rrq_bytenum_r;
        else
                vrh_byte_r <= vrh_byte_r;
end

//line input
//------------ 1st block in -------------------
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_line0_r <= 3'b000;
        else
                vrh_line0_r <= vrh_line0_sig;
 end

assign vrh_line0_sig = ((vrh_requ_blk_r == 1'b0)&&(vrh_request_r==1'b1))? vrh_rrq_linenum_r: vrh_line0_r;

//------------ 2nd block in -------------------
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_line1_r <= 3'b000;
        else
                vrh_line1_r <= vrh_line1_sig;
 end

assign vrh_line1_sig = ((vrh_requ_blk_r == 1'b1)&&(vrh_request_r==1'b1))? vrh_rrq_linenum_r: vrh_line1_r;

//------------ 1st or 2nd que change -------------------
assign vrh_line_que_out = (vrh_end_block_sig == 1'b0)? vrh_line0_r : vrh_line1_r;

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_line_r <= 3'b000;
        else if (vrh_end_block==1'b1)
                vrh_line_r <= vrh_line_que_out;
        else if (vrh_que2_flag_emp)
                vrh_line_r <= vrh_rrq_linenum_r;
        else
                vrh_line_r <= vrh_line_r;
end

//common signal                : for counter enable signal

assign vrh_gnt_req = ((ph_vh_1_gnt==1'b1)&(vh_1_ph_req==1'b1));
assign vrh_accep_request =(vrh_accep_r==1'b1)&(vrh_request_r==1'b1);
assign vrh_req_and = (vrh_req_sig==1'b1)&&(vh_1_ph_req==1'b0);


always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
            vrh_request_r <= 0;
  else
            vrh_request_r <=  f_request_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
            vrh_accep_r <= 0;
  else
            vrh_accep_r <=  vrh_acceptance_r;
end


//Y or C change signal  
always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_requ_blk_r <= 1'b0;
        else if (vrh_accep_request)
                vrh_requ_blk_r <= ~vrh_requ_blk_r;  
        else
                vrh_requ_blk_r <= vrh_requ_blk_r;
end

//flag for que 2
always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que2_flag1_r <= 1'b0;
        else if ((vrh_request_r==1'b1)&&(vrh_requ_blk_r==1'b0))
                 vrh_que2_flag1_r <= 1'b1;
        else if ((vrh_end_blk_chan_r==1'b0)&&(vrh_end_block==1'b1))
                 vrh_que2_flag1_r <= 1'b0;
        else
                vrh_que2_flag1_r <= vrh_que2_flag1_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que2_flag2_r <= 1'b0;
        else if ((vrh_request_r==1'b1)&&(vrh_requ_blk_r==1'b1))
                 vrh_que2_flag2_r <= 1'b1;
        else if ((vrh_end_blk_chan_r==1'b1)&&(vrh_end_block==1'b1))
                 vrh_que2_flag2_r <= 1'b0;
        else
                vrh_que2_flag2_r <= vrh_que2_flag2_r;
end

assign  vrh_que2_flag_full = ((vrh_que2_flag1_r==1'b1)&(vrh_que2_flag2_r==1'b1));
assign  vrh_que2_flag_emp = ((vrh_que2_flag1_r==1'b0)&(vrh_que2_flag2_r==1'b0));

assign  vrh_que2_flag_whi = ((vrh_end_block==1'b1)&&(((vrh_que2_flag1_r==1'b0)&&(vrh_que2_flag2_r==1'b1))
                           ||((vrh_que2_flag1_r==1'b1)&&(vrh_que2_flag2_r==1'b0))));

//acceptance create 
always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
    vrh_acceptance_r <= 1'b0;
        else if ((vrh_request_r== 1'b1)||(f_request_r== 1'b1)||(vrh_que2_flag_full==1'b1))
                vrh_acceptance_r <= 1'b0;
        else if (vrh_que2_flag_full!=1'b1)
                vrh_acceptance_r <= 1'b1;
  else
    vrh_acceptance_r <= vrh_acceptance_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
    vrh_acceptance_rd <= 1'b0;
        else 
    vrh_acceptance_rd <= vrh_acceptance_r;
end

//req create
assign  vrh_req_sig = f_req(ph_vh_1_gnt,vrh_que_full_r,vrh_request_r,vrh_que2_flag_emp,
//assign  vrh_req_sig = f_req(ph_vh_1_gnt,vrh_que_full_r,vh_1_ph_lck,vrh_request_r,vrh_que2_flag_emp,
                      vrh_que_release,vrh_que2_flag_whi,vh_1_ph_req);

function      f_req;
        input    gnt;
        input    full_1_r;
        input    v_request;
        input    emp2;
        input    rele;
        input    whi;
        input    hold;

        begin
         if({rele,emp2}==2'b11)
                f_req = 1'b0;
         else if(({gnt,full_1_r}==3'b111) || ({full_1_r,v_request,whi} == 3'b010) || ({rele,whi} == 2'b10))
           f_req = 1'b1;
         else if(({gnt,full_1_r}==3'b110) || (emp2 == 1'b1)||(whi == 1'b1))
           f_req = 1'b0;
         else
           f_req = hold;
        end
endfunction

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
            vh_1_ph_req <= 0;
  else
            vh_1_ph_req <=  vrh_req_sig ^ vrh_lck ;
end


always @(posedge clkdec or negedge rstdec_x)      
begin
  if (!rstdec_x)
    vrh_cnt_18byte_r <= 2'b00;
        else if(vrh_gnt_req==1'b1)  
            if((vrh_cnt_18byte_r==2'b10)||(vrh_end_block==1'b1)||(vrh_byte_r[1]==1'b0))
                vrh_cnt_18byte_r <= 2'b00;
            else
                vrh_cnt_18byte_r <= vrh_cnt_18byte_r + 1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
    vrh_cnt_16byte_r <= 2'b00;
        else if(vrh_gnt_req==1'b1)  
            if((vrh_end_block==1'b1)||(vrh_byte_r[0]==1'b0))
                vrh_cnt_16byte_r <= 2'b00;
      else
    vrh_cnt_16byte_r <= vrh_cnt_16byte_r - 1;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
    vrh_cnt_line_r <= 4'b0000;
  else if ((vrh_end_block==1'b1)&&(vrh_gnt_req==1'b1))
    vrh_cnt_line_r <= 4'b0000;
  else if ((vrh_cnt_enable==1'b1)&&(vrh_gnt_req==1'b1))
    vrh_cnt_line_r <= vrh_cnt_line_r + 1;
end

assign vrh_line59_lck = (((vrh_cnt_line_r==4'b0100)&(vrh_line_r==3'b011))
      |((vrh_cnt_line_r==4'b1000)&(vrh_line_r==3'b101)));

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
    vrh_lck_168_r <= 3'b000;
     else
    vrh_lck_168_r <= vrh_lck_168_r + 1;
end

assign vrh_excep_sig = ((vrh_request_r==1'b1)&(vh_1_ph_req==1'b0)&(vrh_que2_flag_emp==1'b1));

assign vrh_18_lck_norm = ~((vrh_lck_168_r == 3'b100)|(vrh_line59_lck));

assign vrh_16_lck_norm = ~((vrh_lck_168_r == 3'b010)|(vrh_line59_lck));

assign vrh_18_lck = (vrh_excep_sig==1'b1)? 1: vrh_18_lck_norm;
assign vrh_16_lck = (vrh_excep_sig==1'b1)? 1: vrh_16_lck_norm;

assign vrh_8_lck = ((vrh_excep_sig)&(vrh_byte_r==2'b00));


assign vrh_lck = lck (vrh_byte_r,vrh_8_lck,vrh_16_lck,vrh_18_lck) ;

function lck;                      
input  [1:0]  vrh_byte_r;
input    vrh_8_lck;
input    vrh_16_lck;
input    vrh_18_lck;

 begin
  case (vrh_byte_r)
      2'b00: lck = vrh_8_lck;
      2'b01: lck = vrh_16_lck;
      2'b10: lck = vrh_18_lck;
    default: lck = 1'b0;
  endcase
 end

endfunction


assign vrh_byte_chan = ~((vrh_byte_r==2'b00)|((vrh_byte_r[1]==1'b1)&(vrh_cnt_18byte_r[1]==1'b0))
                        |((vrh_byte_r[0]==1'b1)&(^(vrh_cnt_16byte_r)==1'b0)));


always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vh_1_ph_add[9:0] <= 10'd0;
        else if (vrh_que2_flag_whi==1'b1)
                vh_1_ph_add[9:0] <= 10'd0;
        else if ((vrh_byte_chan==1'b0)&&(vrh_gnt_req==1'b1))
                vh_1_ph_add[9:0] <= vh_1_ph_add[9:0] + 1;
        else if ((vrh_byte_chan==1'b1)&&(vrh_gnt_req==1'b1))
                vh_1_ph_add[9:0] <= vrh_add_que_out[9:0];
        else if (vrh_que2_flag_emp)        
                vh_1_ph_add[9:0] <= vrh_rrq_add[9:0];
end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vh_1_ph_add[26:10] <= 17'd0;
        else if (vrh_que2_flag_whi==1'b1)
                vh_1_ph_add[26:10] <= 17'd0;
        else if (vrh_end_block==1'b1)
                vh_1_ph_add[26:10] <= vrh_add_que_out[26:10];
        else if ((vrh_line_chan==1'b1)&&(vrh_gnt_req==1'b1))
                vh_1_ph_add[26:10] <= vh_1_ph_add[26:10] + 1;
        else if (vrh_que2_flag_emp)        
                vh_1_ph_add[26:10] <= vrh_rrq_add[26:10];
end


always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vh_1_ph_add[31:27] <= 5'd0;
  else if ((vrh_que2_flag_whi==1'b1)||(vrh_req_sig==1'b0))
            vh_1_ph_add[31:27] <= 5'd0;
        else
                vh_1_ph_add[31:27] <=vrh_rrq_fldstatadd_r[31:27];
end

assign vrh_opc_18byte = opc_18byte (vrh_cnt_18byte_r) ;

function [7:0]  opc_18byte;
input  [1:0]  vrh_cnt_18byte_r;

 begin
  case (vrh_cnt_18byte_r)
      2'b00: opc_18byte = P_LOAD18;    //opc_18byte = 8'b00110001
      2'b01: opc_18byte = P_LOAD18;
      2'b10: opc_18byte = P_LOAD18;
    default: opc_18byte = 8'd0;
  endcase
 end

endfunction 

assign vrh_opc_16byte = opc_16byte (vrh_cnt_16byte_r[0]) ;

function [7:0] opc_16byte;
input     vrh_cnt_16byte_r_0;

 begin
  case (vrh_cnt_16byte_r_0)
       1'b1: opc_16byte = P_LOAD16;    //opc_18byte = 8'b00110001
       1'b0: opc_16byte = P_LOAD16;
  endcase
 end

endfunction 

assign vrh_opc_out = opc_sel (vrh_byte_r,vrh_opc_16byte,vrh_opc_18byte) ;

function [7:0]  opc_sel;
input  [1:0]  vrh_byte_r;
input  [7:0]  vrh_opc_16byte;
input  [7:0]  vrh_opc_18byte;

 begin
  case (vrh_byte_r)
      2'b00: opc_sel = P_LOAD08;   
      2'b01: opc_sel = vrh_opc_16byte;
      2'b10: opc_sel = vrh_opc_18byte;
    default: opc_sel = 8'd0;
  endcase
 end

endfunction 


assign vrh_line_case = line_case(vrh_line_r) ;

function [3:0]  line_case;
input  [2:0]  vrh_line_r;

 begin
  case (vrh_line_r)
  3'b001: line_case=4'b0010;
  3'b010: line_case=4'b0100;
  3'b011: line_case=4'b0101;
  3'b100: line_case=4'b1000;
  3'b101: line_case=4'b1001;
       default: line_case=4'b0000;
  endcase
 end

endfunction


assign vrh_line_finish = ((vrh_line_case!=4'b0000)&(vrh_gnt_req)&(vrh_cnt_line_r==vrh_line_case));      //8byte

assign vrh_18byte_end = ((vrh_line_finish)&(vrh_cnt_18byte_r==2'b10));     //18byte only

assign vrh_16byte_end = ((vrh_line_finish)&(^(vrh_cnt_16byte_r)==1'b1));     //16byte only

assign vrh_cnt_enable = enable_sel (vrh_byte_r,vrh_cnt_16byte_r[0],vrh_cnt_18byte_r[0]) ;

function enable_sel;
input  [1:0]  vrh_byte_r;
input    vrh_cnt_16byte_r_0;
input    vrh_cnt_18byte_r_0;

 begin
  case (vrh_byte_r)
      2'b00: enable_sel = 1'b1;
      2'b01: enable_sel = ~vrh_cnt_16byte_r_0;
      2'b10: enable_sel = vrh_cnt_18byte_r_0;
    default: enable_sel = 1'b0;
  endcase
 end

endfunction

assign vrh_line_chan = line_chan (vrh_byte_r,vrh_cnt_16byte_r[0],vrh_cnt_18byte_r[1]) ;

function line_chan;
input   [1:0]   vrh_byte_r;
input           vrh_cnt_16byte_r_0;
input           vrh_cnt_18byte_r_1;

 begin
  case (vrh_byte_r)
      2'b00: line_chan = 1'b0;
      2'b01: line_chan = vrh_cnt_16byte_r_0;
      2'b10: line_chan = vrh_cnt_18byte_r_1;
    default: line_chan = 1'b0;
  endcase
 end

endfunction

assign vrh_end_block = block_end (vrh_byte_r,vrh_16byte_end,vrh_18byte_end,vrh_line_finish) ;

function block_end;
input   [1:0]   vrh_byte_r;
input    vrh_16byte_end;
input           vrh_18byte_end;
input           vrh_line_finish;

 begin
  case (vrh_byte_r)
      2'b00: block_end = vrh_line_finish;
      2'b01: block_end = vrh_16byte_end;
      2'b10: block_end = vrh_18byte_end;
    default: block_end = 1'b0;
  endcase
 end

endfunction

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
     vrh_line_enable18_r <= 1'b0;
        else if (vrh_req_sig==1'b0)
                vrh_line_enable18_r <= 1'b0;

  else if (((vrh_cnt_18byte_r==2'b10)&&(vrh_gnt_req==1'b1))
         ||((vrh_cnt_18byte_r[0]==1'b0)&&(vrh_line_chan==1'b0)&&(vrh_req_and))
         ||((vrh_end_block)&&(vrh_req_sig==1'b1)))
        vrh_line_enable18_r <= 1'b1;

  else
     vrh_line_enable18_r <= 1'b0;
end

always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
     vrh_line_enable16_r <= 1'b0;

        else if (vrh_req_sig==1'b0)
                vrh_line_enable16_r <= 1'b0;

  else if (((vrh_cnt_16byte_r[0]==1'b1)&&(vrh_gnt_req==1'b1)&&(~vrh_que2_flag_whi))
         ||((vrh_cnt_16byte_r[0]==1'b0)&&(vrh_line_chan==1'b0)&&(vrh_req_and))
         ||((vrh_end_block)&&(vrh_req_sig==1'b1)))
        vrh_line_enable16_r <= 1'b1;

  else 
        vrh_line_enable16_r <= 1'b0;
end

assign vrh_line_enable = line_enable (vrh_byte_r,vrh_line_enable16_r,vrh_line_enable18_r) ;

function line_enable;
input  [1:0]  vrh_byte_r;
input    vrh_line_enable16_r;
input    vrh_line_enable18_r;

 begin
  case (vrh_byte_r)
      2'b01: line_enable = vrh_line_enable16_r;
      2'b10: line_enable = vrh_line_enable18_r;
    default: line_enable = 1'b0;
  endcase
 end

endfunction

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_type0_r <= 3'b000;
        else
                vrh_type0_r <= vrh_type0_sig;
 end

assign vrh_type0_sig = ((vrh_requ_blk_r == 1'b0)&&(vrh_request_r==1'b1))? vrh_rrq_addx_r[2:0]: vrh_type0_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_type1_r <= 3'b000;
        else
                vrh_type1_r <= vrh_type1_sig;
 end

assign vrh_type1_sig = ((vrh_requ_blk_r == 1'b1)&&(vrh_request_r==1'b1))? vrh_rrq_addx_r[2:0]: vrh_type1_r - 1'b1;

assign vrh_type_que_out = (vrh_end_block_sig == 1'b0)? vrh_type0_r : vrh_type1_r;

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_type_r <= 3'b000;
        else
                vrh_type_r <= vrh_type_r + vrh_type_que_out;
end


assign vrh_line_type = (vrh_line_enable==1'b1)? {vrh_byte_r[1],vrh_type_r}: 4'b0000;


endmodule













