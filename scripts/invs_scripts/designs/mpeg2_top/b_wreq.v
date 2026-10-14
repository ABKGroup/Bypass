// ----------------------------------------------
// File: b_wreq.v
// Module: b_wreq
// Function:BusI/F(R) request issue control
// ----------------------------------------------

module b_wreq(
                clkdec,      
                rstdec_x,    
                g_field_start_add_r, // field0 address
                g_field_offset_r,    // field size offset (byte)
                g_cbcr_offset_r,     // CbCr size offset (byte)
                g_line_offset_r,     // line offset
                b_request_r,         // block request (from BDC)
                b_field_num_r,       // field number
                b_addressx_r,        // X-axis address (X/8 in field)
                b_addressy_r,        // Y-axis address (Y/2 in field)
                b_byte_num_r,        // byte number (in line)
                b_line_num_r,        // line number (in block)
                ph_vh_2_gnt,         // SHwy grant
                vwh_wdc_dataready,   // Write data OK
                b_write_enable_r,    // write_data enable (from BDC)
                vwh_acceptance_r,    // request acceptance signals
                vh_2_ph_req,         // SHwy request
                vh_2_ph_add,         // SHwy address
                vwh_wrq_tranacc      // SHwy request
                );

    parameter            P_F_OFFSET = 11;   // field offset signal width
    parameter            P_F_NUM_WH = 3;    // field number signal width
    parameter            P_X_WIDTHX = 8;    // from BDC X-address width
    parameter            P_Y_WIDTHX = 9;    // from BDC Y-address width
    parameter            P_F_MSBALI = 'd26; // address calcuration most significant bit
    parameter            P_F_LSBALI = 'd10; // 1KB aline bit width

    parameter            P_NUM0XXXX =4'h0;  // number 0
    parameter            P_NUM1XXXX =4'h1;  // number 1
    parameter            P_NUM3XXXX =4'h3;  // number 3
    parameter            P_NUM4XXXX =4'h4;  // number 4
    parameter            P_NUM7XXXX =4'h7;  // number 7
    parameter            P_NUM8XXXX =4'h8;  // number 8

    parameter            P_OPCODE8X =8'b0011_0010; // STORE8
    parameter            P_OPCODE16 =8'b0100_0010; // STORE16

    input                  clkdec;              // 108MHz Clock (dec)
    input                  rstdec_x;            // reset
    input [31:10]          g_field_start_add_r; // field0 address
    input [P_F_OFFSET:0]   g_field_offset_r;    // field size offset (byte)
    input [P_F_OFFSET:0]   g_cbcr_offset_r;     // CbCr size offset (byte)
    input                  g_line_offset_r;     // line offset
    input                  b_request_r;         // block request (from BDC)
    input [3:0]            b_field_num_r;       // field number
    input [P_X_WIDTHX-1:0] b_addressx_r;        // X-axis address (X/8 in field)
    input [P_Y_WIDTHX-1:0] b_addressy_r;        // Y-axis address (Y/2 in field)
    input [1:0]            b_byte_num_r;        // byte number (in line)
    input [2:0]            b_line_num_r;        // line number (in block)
    input                  ph_vh_2_gnt;         // SHwy grant
    input                  vwh_wdc_dataready;   // Write data OK
    input                  b_write_enable_r;    // write_data enable (from BDC)
    output                 vwh_acceptance_r;    // request acceptance signals
    output                 vh_2_ph_req;         // SHwy request
    output [31:0]          vh_2_ph_add;         // SHwy address
    output                 vwh_wrq_tranacc;     // SHwy request

    wire                   clkdec;              // 108MHz Clock (dec)
    wire                   rstdec_x;            // reset
    wire [31:10]           g_field_start_add_r; // field0 address
    wire [P_F_OFFSET:0]    g_field_offset_r;    // field size offset (byte)
    wire [P_F_OFFSET:0]    g_cbcr_offset_r;     // CbCr size offset (byte)
    wire                   g_line_offset_r;     // line offset
    reg                    vwh_acceptance_r;    // request acceptance signals
    reg                    vh_2_ph_req;         // SHwy request
    wire                   ph_vh_2_gnt;         // SHwy grant
    reg [31:0]             vh_2_ph_add;         // SHwy address
    wire                   vwh_wdc_dataready;   // Write data OK
    wire                   vwh_wrq_tranacc;     // SHwy request
    
    wire                   vwh_wrq_request;         // request from BDC (with acceptance)
    reg                    vwh_wrq_request_r;       // make F/F vwh_wrq_request_r
    reg                    vwh_wrq_accequesel_r;    // select signal acceptance que
    wire                   vwh_wrq_quefull;         // que full
    wire                   vwh_wrq_queexist;        // que exit
    reg                    vwh_wrq_que0flag_r;      // que0 exit
    reg                    vwh_wrq_que1flag_r;      // que1 exit
    reg [1:0]              vwh_wrq_que0xtranum_r;   // que0 X-axis transaction number
    reg [3:0]              vwh_wrq_que0ytranum_r;   // que0 Y-axis transaction number
    reg [1:0]              vwh_wrq_que1xtranum_r;   // que1 X-axis transaction number
    reg [3:0]              vwh_wrq_que1ytranum_r;   // que1 Y-axis transaction number
    wire                   vwh_wrq_que0end;         // que0 issue end
    wire                   vwh_wrq_que1end;         // que1 issue end
    wire                   vwh_wrq_curqueend;       // current que issue end
    reg                    vwh_wrq_issquesel_r;     // issue que select 
    reg                    vwh_wrq_issquenxtsel_r;  // issue que select before 1 cell
    reg                    vwh_wrq_issquech;        // issue change
    reg [1:0]              vwh_wrq_bytecnt_r;       // byte counter in line
    reg [3:0]              vwh_wrq_linecnt_r;       // line counter in block
    wire                   vwh_wrq_blkissend;       // issue block end
    wire                   vwh_wrq_nxtline;         // go next line sign
    reg [1:0]              vwh_wrq_xtranumold_r;    // hold current X-axis transaction in block end
    wire [1:0]             vwh_wrq_selxtranum;      // select que0xtranum or que1xtranum
    wire [1:0]             vwh_wrq_curxtranum;      // current X-axis
    wire [1:0]             vwh_wrq_nxtxtranum;      // next issue X-axis tarnasaction number
    wire                   vwh_wrq_nxtblk;          // last line in block
    wire [3:0]             vwh_wrq_curytranum;      // current Y-axis
    wire                   vwh_wrq_byte0cnt;        // byte counter is 0
    wire                   vwh_wrq_byte1cnt;        // byte counter is 1
    wire                   vwh_wrq_opcend;          // 1 packet end
    wire                   vwh_wrq_nxtiss_stop_sig; // can't issue next block
    wire                   vwh_wrq_nxtqueemp;       // next que flag is empty
    wire [P_F_MSBALI:0]    vwh_wrq_seladd;          // select que0 add or que1 add
    reg [P_X_WIDTHX-1:0]   vwh_wrq_addx_r;          // F/F b_addressx_r 
    reg [P_Y_WIDTHX-1:0]   vwh_wrq_addy_r;          // F/F b_addressy_r 
    reg [1:0]              vwh_wrq_bytenum_r;       // F/F b_byte_num_r
    reg [2:0]              vwh_wrq_linenum_r;       // F/F b_line_num_r
    reg [3:0]              vwh_wrq_fldnum_r;        // F/F b_field_num_r
    wire                   vwh_wrq_chaccque;        // que0 or que1 renew
    reg                    vwh_wrq_fullaccept_r;    // when quefull and 1 request(BDC) is accepted
    wire                   vwh_wrq_que0wait;        // que0 is in use
    wire                   vwh_wrq_que1wait;        // que1 is in use
    reg                    vwh_wrq_que0wait_r;      // wait for renewal que0 address data and so on
    reg                    vwh_wrq_que1wait_r;      // wait for renewal que1 address data and so on
    wire                   vwh_wrq_renewque0;       // renew que0
    wire                   vwh_wrq_renewque1;       // renew que1
    reg [P_F_MSBALI:0]     vwh_wrq_nxtadd;          // issue next packet address
    wire [1:0]             vwh_wrq_1linebyte;       // byte number in line on SDRAM
    reg [P_F_MSBALI:0]     vwh_wrq_que0add_r;       // que0 address
    reg [P_F_MSBALI:0]     vwh_wrq_que1add_r;       // que1 address

    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld1_r;      // field 1 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld2_r;      // field 2 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld3_r;      // field 3 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld4_r;      // field 4 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld5_r;      // field 5 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld6_r;      // field 6 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld7_r;      // field 7 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld8_r;      // field 8 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld9_r;      // field 9 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld10_r;     // field 10 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld11_r;     // field 11 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld12_r;     // field 12 head address
    reg [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld13_r;     // field 13 head address
    wire [P_F_OFFSET+1:0]       vwh_wrq_fldoft2;     // field 2 offset value
    reg [P_F_OFFSET+2:0]        vwh_wrq_fldoft3_r;   // field 3 offset value
    wire [P_F_OFFSET+2:0]       vwh_wrq_fldoft4;     // field 4 offset value
    reg [P_F_OFFSET+3:0]        vwh_wrq_fldoft5_r;   // field 5 offset value
    wire [P_F_OFFSET+3:0]       vwh_wrq_fldoft6;     // field 6 offset value
    wire [P_F_OFFSET+3:0]       vwh_wrq_fldoft7;     // field 7 offset value
    wire [P_F_OFFSET+3:0]       vwh_wrq_fldoft8;     // field 8 offset value
    wire [P_F_OFFSET+4:0]       vwh_wrq_fldoft9;     // field 9 offset value
    wire [P_F_OFFSET+4:0]       vwh_wrq_fldoft10;    // field 10 offset value
    wire [P_F_OFFSET+4:0]       vwh_wrq_fldoft11;    // field 11 offset value
    wire [P_F_OFFSET+4:0]       vwh_wrq_fldoft12;    // field 12 offset value
    wire [P_F_OFFSET+4:0]       vwh_wrq_fldoft13;    // field 13 offset value

    reg                         vwh_wrq_nxtiss_stop_r; // stop next issue SHwy request
    reg [31:10]                  vwh_wrq_fldstatadd_r; // F/F g_field_start_add_r
    reg [P_F_OFFSET:0]          vwh_wrq_fldoft_r;      // F/F g_field_offset_r
    reg [P_F_OFFSET:0]          vwh_wrq_cbcroft_r;     // F/F g_cbcr_offset_r
    reg                         vwh_wrq_lineoft_r;     // F/F g_line_offset_r

    wire [P_F_MSBALI:0]         vwh_wrq_add;           // block head address calculate value
    wire [2:0]                  vwh_wrq_aline1kadd;    // near 1KB aline address calulate value
    wire [P_F_MSBALI:P_F_LSBALI] vwh_wrq_selycbcradd;  // select Y or CbCr address
    wire [P_Y_WIDTHX + 1:0]      vwh_wrq_iniyaddsft;   // Y-axis address 
    wire [P_F_MSBALI:P_F_LSBALI] vwh_wrq_curcbcradd;   // current CbCr address
    wire [P_F_MSBALI:P_F_LSBALI] vwh_wrq_selfldadd;    // select field head address

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_request_r <= 1'b0;
        else 
            vwh_wrq_request_r <= vwh_wrq_request;
    end
    
     assign vwh_wrq_request = vwh_acceptance_r & b_request_r;

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vwh_wrq_addx_r[P_X_WIDTHX-1:0] <= 8'h00;
            vwh_wrq_addy_r[P_Y_WIDTHX-1:0] <= 9'h00;
            vwh_wrq_bytenum_r[1:0] <= 2'b00;
            vwh_wrq_linenum_r[2:0] <= 3'b000;
            vwh_wrq_fldnum_r[3:0]  <= 4'b0000;
        end else if(vwh_wrq_request)begin
                vwh_wrq_addx_r[P_X_WIDTHX-1:0] <= b_addressx_r[P_X_WIDTHX-1:0];
                vwh_wrq_addy_r[P_Y_WIDTHX-1:0] <= b_addressy_r[P_Y_WIDTHX-1:0];
                vwh_wrq_bytenum_r[1:0] <= b_byte_num_r[1:0];
                vwh_wrq_linenum_r[2:0] <= b_line_num_r[2:0];
                vwh_wrq_fldnum_r[3:0]  <= b_field_num_r[3:0];
        end 
    end 
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_accequesel_r <= 1'b0;
        else begin 
            if(vwh_wrq_chaccque)
                vwh_wrq_accequesel_r <= ~vwh_wrq_accequesel_r;
        end
    end
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_acceptance_r <= 1'b1;
        else begin
            if(vwh_wrq_request || vwh_wrq_fullaccept_r)
                vwh_acceptance_r <= 1'b0;
            else
                vwh_acceptance_r <= 1'b1;
        end
    end
    
     always@(posedge clkdec or negedge rstdec_x)begin
         if(!rstdec_x)
             vwh_wrq_fullaccept_r <= 1'b0;
         else begin
             if(vwh_wrq_quefull)begin
                 if(vwh_wrq_request)
                     vwh_wrq_fullaccept_r <= 1'b1;
                 else if(vwh_wrq_chaccque)
                     vwh_wrq_fullaccept_r <= 1'b0;
             end else
                 vwh_wrq_fullaccept_r <= 1'b0;
         end 
     end 
    
    
    assign vwh_wrq_chaccque = vwh_wrq_renewque0 | vwh_wrq_renewque1;
    assign vwh_wrq_que0wait = vwh_wrq_request_r & vwh_wrq_que0flag_r & (~vwh_wrq_accequesel_r);
    assign vwh_wrq_que1wait = vwh_wrq_request_r & vwh_wrq_que1flag_r & (vwh_wrq_accequesel_r);
    assign vwh_wrq_renewque0 = (~vwh_wrq_accequesel_r &
                                ((~vwh_wrq_que0flag_r & vwh_wrq_request_r) ||
                                 ((~vwh_wrq_issquesel_r) & (vwh_wrq_blkissend & vwh_wrq_que0wait_r))));
    assign vwh_wrq_renewque1 = (vwh_wrq_accequesel_r &
                                ((~vwh_wrq_que1flag_r & vwh_wrq_request_r) ||
                                 ((vwh_wrq_issquesel_r) & (vwh_wrq_blkissend & vwh_wrq_que1wait_r))));

    assign vwh_wrq_quefull = vwh_wrq_que0flag_r & vwh_wrq_que1flag_r;
    assign vwh_wrq_queexist = vwh_wrq_que0flag_r | vwh_wrq_que1flag_r;
    assign vwh_wrq_nxtqueemp = (vwh_wrq_issquesel_r) ?
                                    ~vwh_wrq_que0flag_r : ~vwh_wrq_que1flag_r;
    assign vwh_wrq_que0end    = (~vwh_wrq_issquesel_r) & (vwh_wrq_issquech==1'b1);
    assign vwh_wrq_que1end    =  vwh_wrq_issquesel_r & (vwh_wrq_issquech==1'b1);

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que0wait_r <= 1'b0;
        else begin
            if(vwh_wrq_que0wait)
                vwh_wrq_que0wait_r <= 1'b1;
            else if(vwh_wrq_renewque0)
                vwh_wrq_que0wait_r <= 1'b0;
        end
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que1wait_r <= 1'b0;
        else begin
            if(vwh_wrq_que1wait)
                vwh_wrq_que1wait_r <= 1'b1;
            else if(vwh_wrq_renewque1)
                vwh_wrq_que1wait_r <= 1'b0;
        end
    end
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que0flag_r <= 1'b0;
        else  begin
            if(vwh_wrq_renewque0)
                vwh_wrq_que0flag_r <= 1'b1;
            else if(ph_vh_2_gnt && vwh_wrq_que0end && (~vwh_wrq_que0wait_r))
                vwh_wrq_que0flag_r <= 1'b0;
        end  
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que0xtranum_r <= 2'b00;
        else  begin
            if(vwh_wrq_renewque0)
                vwh_wrq_que0xtranum_r <= vwh_wrq_bytenum_r;
        end
    end 

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que0ytranum_r <= 4'h0;
        else  begin
            if(vwh_wrq_renewque0)begin
                case (vwh_wrq_linenum_r[2:0])
                    3'b000:vwh_wrq_que0ytranum_r <= P_NUM0XXXX;
                    3'b001:vwh_wrq_que0ytranum_r <= P_NUM1XXXX;
                    3'b010:vwh_wrq_que0ytranum_r <= P_NUM3XXXX;
                    3'b011:vwh_wrq_que0ytranum_r <= P_NUM4XXXX;
                    3'b100:vwh_wrq_que0ytranum_r <= P_NUM7XXXX;
                    3'b101:vwh_wrq_que0ytranum_r <= P_NUM8XXXX;
                    default:vwh_wrq_que0ytranum_r <= 4'bxxxx;
                endcase
            end 
        end 
    end
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que1flag_r <= 1'b0;
        else  begin
            if(vwh_wrq_renewque1)
                vwh_wrq_que1flag_r <= 1'b1;
            else if(ph_vh_2_gnt && vwh_wrq_que1end && (~vwh_wrq_que1wait_r))
                vwh_wrq_que1flag_r <= 1'b0;
        end
    end 

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que1xtranum_r <= 2'b00;
        else  begin
            if(vwh_wrq_renewque1)
                vwh_wrq_que1xtranum_r <= vwh_wrq_bytenum_r;
        end
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que1ytranum_r <= 4'h0;
        else  begin
            if(vwh_wrq_renewque1)begin
                case (vwh_wrq_linenum_r[2:0])
                    3'b000:vwh_wrq_que1ytranum_r <= P_NUM0XXXX;
                    3'b001:vwh_wrq_que1ytranum_r <= P_NUM1XXXX;
                    3'b010:vwh_wrq_que1ytranum_r <= P_NUM3XXXX;
                    3'b011:vwh_wrq_que1ytranum_r <= P_NUM4XXXX;
                    3'b100:vwh_wrq_que1ytranum_r <= P_NUM7XXXX;
                    3'b101:vwh_wrq_que1ytranum_r <= P_NUM8XXXX;
                    default:vwh_wrq_que1ytranum_r <= 4'bxxxx;
                endcase
            end
        end
    end 
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_bytecnt_r <= 2'b00;
        else  begin
            if(vwh_wrq_tranacc)begin
                if(vwh_wrq_nxtline)
                    vwh_wrq_bytecnt_r <= 2'b00;
                else
                    vwh_wrq_bytecnt_r <= vwh_wrq_bytecnt_r + 1'b1;
            end
        end
    end

    assign vwh_wrq_blkissend = (vwh_wrq_issquenxtsel_r != vwh_wrq_issquesel_r);
    assign vwh_wrq_nxtline = (vwh_wrq_bytecnt_r == vwh_wrq_curxtranum);
    assign vwh_wrq_selxtranum = (vwh_wrq_issquesel_r)? vwh_wrq_que1xtranum_r:vwh_wrq_que0xtranum_r;
    assign vwh_wrq_curxtranum = (vwh_wrq_blkissend)?vwh_wrq_xtranumold_r:vwh_wrq_selxtranum;
    assign vwh_wrq_nxtxtranum =(vwh_wrq_issquenxtsel_r)? vwh_wrq_que1xtranum_r:vwh_wrq_que0xtranum_r;
    assign vwh_wrq_curytranum =(vwh_wrq_issquesel_r)? vwh_wrq_que1ytranum_r:vwh_wrq_que0ytranum_r;
    assign vwh_wrq_nxtblk = (vwh_wrq_linecnt_r == vwh_wrq_curytranum);
    assign vwh_wrq_curqueend = (((vwh_wrq_linecnt_r == vwh_wrq_curytranum - 1'b1 ) &
                                 vwh_wrq_nxtline) & vh_2_ph_req);
    assign vwh_wrq_byte0cnt = (vwh_wrq_bytecnt_r == 2'b00);
    assign vwh_wrq_byte1cnt = (vwh_wrq_bytecnt_r == 2'b01);

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_xtranumold_r <= 2'b00;
        else  begin
            if(vwh_wrq_que0end || vwh_wrq_que1end)
                vwh_wrq_xtranumold_r <= vwh_wrq_curxtranum;
        end
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_linecnt_r <= 4'b0000;
        else  begin
            if(vwh_wrq_opcend)begin
                if(vwh_wrq_blkissend)
                    vwh_wrq_linecnt_r <= 4'b0000;
                else if(vwh_wrq_nxtline)
                    vwh_wrq_linecnt_r <= vwh_wrq_linecnt_r + 1'b1;
            end    
        end
    end
                    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_issquesel_r <= 1'b0;
        else  begin
            if(vh_2_ph_req & vwh_wrq_blkissend & ph_vh_2_gnt)
                vwh_wrq_issquesel_r <= ~vwh_wrq_issquesel_r;
        end
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_issquenxtsel_r <= 1'b0;
        else  begin
            if(vwh_wrq_issquech && vwh_wrq_tranacc)
                vwh_wrq_issquenxtsel_r <= ~vwh_wrq_issquenxtsel_r;
        end
    end

    always@(vwh_wrq_curxtranum or
            vwh_wrq_curqueend or
            vwh_wrq_nxtblk or
            vwh_wrq_byte0cnt or
            vwh_wrq_byte1cnt)begin
        case (vwh_wrq_curxtranum)
            2'b00:vwh_wrq_issquech = vwh_wrq_curqueend;
            2'b01:vwh_wrq_issquech = vwh_wrq_nxtblk & vwh_wrq_byte0cnt;
            2'b10:vwh_wrq_issquech = vwh_wrq_nxtblk & vwh_wrq_byte1cnt;
            2'b11:vwh_wrq_issquech = vwh_wrq_curqueend;
        endcase
    end

    assign vwh_wrq_opcend = (vh_2_ph_req & ph_vh_2_gnt);
    assign vwh_wrq_tranacc = vh_2_ph_req & ph_vh_2_gnt;
    
    assign vwh_wrq_nxtiss_stop_sig = (vwh_wrq_issquech & vwh_wrq_nxtqueemp & (~vwh_wrq_request_r));

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_nxtiss_stop_r <= 1'b0;
        else if(ph_vh_2_gnt)
                vwh_wrq_nxtiss_stop_r <= vwh_wrq_nxtiss_stop_sig;
    end 
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vh_2_ph_req <= 1'b0;
        else  begin
            if(vwh_wrq_opcend)begin
                if(vwh_wrq_blkissend && (vwh_wrq_nxtiss_stop_r || (~b_write_enable_r)))
                    vh_2_ph_req <= 1'b0;
            end else if(vwh_wrq_queexist && vwh_wdc_dataready)
                vh_2_ph_req <= 1'b1;
        end
    end 


    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vh_2_ph_add <= 32'h0000_0000;
        else  begin
            if(vh_2_ph_req)begin
                if(ph_vh_2_gnt)begin
                    if(vwh_wrq_blkissend)begin
                        if(vwh_wrq_nxtiss_stop_r  || (~b_write_enable_r))
                            vh_2_ph_add <= 32'h000_0000;
                        else  
                            vh_2_ph_add <= {vwh_wrq_fldstatadd_r[31:P_F_MSBALI + 1],vwh_wrq_seladd};
                    end else
                        vh_2_ph_add <= {vwh_wrq_fldstatadd_r[31:P_F_MSBALI + 1],vwh_wrq_nxtadd};
                end else if(vwh_wrq_queexist && vwh_wdc_dataready)
                    vh_2_ph_add <= {vwh_wrq_fldstatadd_r[31:P_F_MSBALI + 1],vwh_wrq_seladd};
            end
        end
    end
    
    assign vwh_wrq_seladd = (vwh_wrq_issquenxtsel_r)? vwh_wrq_que1add_r: vwh_wrq_que0add_r - 1;

    always@(vwh_wrq_nxtline or
            vwh_wrq_issquesel_r or
            vwh_wrq_que0add_r or
            vwh_wrq_que1add_r or
            vwh_wrq_1linebyte or
            vwh_wrq_curxtranum or
            vh_2_ph_add)begin
        if(vwh_wrq_nxtline)begin
            case (vwh_wrq_issquesel_r)
                1'b0:vwh_wrq_nxtadd[P_F_LSBALI-1:0] = vwh_wrq_que0add_r[P_F_LSBALI-1:0];
                1'b1:vwh_wrq_nxtadd[P_F_LSBALI-1:0] = vwh_wrq_que1add_r[P_F_LSBALI-1:0];
            endcase
            vwh_wrq_nxtadd[P_F_MSBALI:P_F_LSBALI] = vh_2_ph_add[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_1linebyte;
        end else begin
            case(vwh_wrq_curxtranum)
                2'b01:vwh_wrq_nxtadd[P_F_LSBALI:0] = vh_2_ph_add[P_F_LSBALI:0];
                default:vwh_wrq_nxtadd[P_F_LSBALI:0] = vh_2_ph_add[P_F_LSBALI:0] + 1'b1;
            endcase
            vwh_wrq_nxtadd[P_F_MSBALI:P_F_LSBALI+1] = vh_2_ph_add[P_F_MSBALI:P_F_LSBALI+1];
        end 
    end 

    assign vwh_wrq_1linebyte = 2'b01 << vwh_wrq_lineoft_r;

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que0add_r <= 27'h00_0000; 
        else  begin
            if(vwh_wrq_renewque0)
                vwh_wrq_que0add_r <= vwh_wrq_add;
        end
    end 

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)
            vwh_wrq_que1add_r <= 24'h00_0000;
        else  begin
            if(vwh_wrq_renewque1)
                vwh_wrq_que1add_r <= vwh_wrq_add;
        end
    end

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vwh_wrq_fldstatadd_r  <= 22'h00_0000;
            vwh_wrq_fldoft_r      <= 12'h000;
            vwh_wrq_cbcroft_r     <= 12'h000;
            vwh_wrq_lineoft_r     <= 1'b0;
        end else  begin
            vwh_wrq_fldstatadd_r  <= g_field_start_add_r;
            vwh_wrq_fldoft_r      <= g_field_offset_r;
            vwh_wrq_cbcroft_r     <= g_cbcr_offset_r;
            vwh_wrq_lineoft_r     <= g_line_offset_r;
        end 
    end 
    
    assign vwh_wrq_fldoft2 = vwh_wrq_fldoft_r << 1;
    assign vwh_wrq_fldoft4 = vwh_wrq_fldoft_r << 2;
    assign vwh_wrq_fldoft8 = vwh_wrq_fldoft_r << 3;
    assign vwh_wrq_fldoft6  = vwh_wrq_fldoft2 + vwh_wrq_fldoft4;
    assign vwh_wrq_fldoft7  = vwh_wrq_fldoft3_r + vwh_wrq_fldoft4;
    assign vwh_wrq_fldoft9  = vwh_wrq_fldoft_r + vwh_wrq_fldoft8;
    assign vwh_wrq_fldoft10 = vwh_wrq_fldoft2 + vwh_wrq_fldoft8;
    assign vwh_wrq_fldoft11 = vwh_wrq_fldoft3_r + vwh_wrq_fldoft8;
    assign vwh_wrq_fldoft12 = vwh_wrq_fldoft4 + vwh_wrq_fldoft8;
    assign vwh_wrq_fldoft13 = vwh_wrq_fldoft5_r + vwh_wrq_fldoft8;

    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vwh_wrq_fldoft3_r <= 13'b0_0000_0000_0000;
            vwh_wrq_fldoft5_r <= 14'b00_0000_0000_0000;
        end else  begin
            vwh_wrq_fldoft3_r  <= vwh_wrq_fldoft_r + vwh_wrq_fldoft2;
            vwh_wrq_fldoft5_r  <= vwh_wrq_fldoft_r + vwh_wrq_fldoft4;
        end
    end
    
    always@(posedge clkdec or negedge rstdec_x)begin
        if(!rstdec_x)begin
            vwh_wrq_fld1_r  <= 17'h00000;
            vwh_wrq_fld2_r  <= 17'h00000;
            vwh_wrq_fld3_r  <= 17'h00000;
            vwh_wrq_fld4_r  <= 17'h00000;
            vwh_wrq_fld5_r  <= 17'h00000;
            vwh_wrq_fld6_r  <= 17'h00000;
            vwh_wrq_fld7_r  <= 17'h00000;
            vwh_wrq_fld8_r  <= 17'h00000;
            vwh_wrq_fld9_r  <= 17'h00000;
            vwh_wrq_fld10_r <= 17'h00000;
            vwh_wrq_fld11_r <= 17'h00000;
            vwh_wrq_fld12_r <= 17'h00000;
            vwh_wrq_fld13_r <= 17'h00000;
        end else  begin
            vwh_wrq_fld1_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft_r;
            vwh_wrq_fld2_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft2;
            vwh_wrq_fld3_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft3_r;
            vwh_wrq_fld4_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft4;
            vwh_wrq_fld5_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft5_r;
            vwh_wrq_fld6_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft6;
            vwh_wrq_fld7_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft7;
            vwh_wrq_fld8_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft8;
            vwh_wrq_fld9_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft9;
            vwh_wrq_fld10_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft10;
            vwh_wrq_fld11_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft11;
            vwh_wrq_fld12_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft12;
            vwh_wrq_fld13_r <= vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI] + vwh_wrq_fldoft13;
        end
    end 

    assign vwh_wrq_add[P_F_MSBALI:P_F_LSBALI] = vwh_wrq_iniyaddsft + 
                                                {vwh_wrq_selycbcradd[P_F_MSBALI:P_F_LSBALI+3],
                                                 vwh_wrq_aline1kadd};
    assign vwh_wrq_add[P_F_LSBALI-1:0] = {vwh_wrq_addx_r[P_X_WIDTHX-2:0],3'b000};
    assign vwh_wrq_aline1kadd = (vwh_wrq_addx_r[P_X_WIDTHX-1] +
                                 vwh_wrq_selycbcradd[P_F_LSBALI+2:P_F_LSBALI]);
    assign vwh_wrq_curcbcradd = vwh_wrq_cbcroft_r + vwh_wrq_selfldadd;
    assign vwh_wrq_selycbcradd = (vwh_wrq_accequesel_r)? vwh_wrq_curcbcradd : vwh_wrq_selfldadd;
    assign vwh_wrq_iniyaddsft = {vwh_wrq_addy_r,1'b0} << vwh_wrq_lineoft_r;
    assign vwh_wrq_selfldadd = vwh_wrq_selfld(vwh_wrq_fldnum_r,
                                               vwh_wrq_fldstatadd_r[P_F_MSBALI:P_F_LSBALI],
                                               vwh_wrq_fld1_r,
                                               vwh_wrq_fld2_r,
                                               vwh_wrq_fld3_r,
                                               vwh_wrq_fld4_r,
                                               vwh_wrq_fld5_r,
                                               vwh_wrq_fld6_r,
                                               vwh_wrq_fld7_r,
                                               vwh_wrq_fld8_r,
                                               vwh_wrq_fld9_r,
                                               vwh_wrq_fld10_r,
                                               vwh_wrq_fld11_r,
                                               vwh_wrq_fld12_r,
                                               vwh_wrq_fld13_r);
        
        function [26:10] vwh_wrq_selfld;
        input [P_F_NUM_WH:0] vwh_wrq_fldnum_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fldstatadd_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld1_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld2_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld3_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld4_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld5_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld6_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld7_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld8_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld9_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld10_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld11_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld12_r;
        input [P_F_MSBALI:P_F_LSBALI] vwh_wrq_fld13_r;
        begin
            case(vwh_wrq_fldnum_r)
                4'b0000: vwh_wrq_selfld = vwh_wrq_fldstatadd_r;
                4'b0001: vwh_wrq_selfld = vwh_wrq_fld1_r;
                4'b0010: vwh_wrq_selfld = vwh_wrq_fld2_r;
                4'b0011: vwh_wrq_selfld = vwh_wrq_fld3_r;
                4'b0100: vwh_wrq_selfld = vwh_wrq_fld4_r;
                4'b0101: vwh_wrq_selfld = vwh_wrq_fld5_r;
                4'b0110: vwh_wrq_selfld = vwh_wrq_fld6_r;
                4'b0111: vwh_wrq_selfld = vwh_wrq_fld7_r;
                4'b1000: vwh_wrq_selfld = vwh_wrq_fld8_r;
                4'b1001: vwh_wrq_selfld = vwh_wrq_fld9_r;
                4'b1010: vwh_wrq_selfld = vwh_wrq_fld10_r;
                4'b1011: vwh_wrq_selfld = vwh_wrq_fld11_r;
                4'b1100: vwh_wrq_selfld = vwh_wrq_fld12_r;
                4'b1101: vwh_wrq_selfld = vwh_wrq_fld13_r;
                default: vwh_wrq_selfld = 17'h00000;
            endcase
        end
    endfunction
    
endmodule









