// ----------------------------------------------
// File: vld_outbuf.v
// Module: vld_outbuf
// Function:generate output data from VLD
// ----------------------------------------------

module vld_outbuf(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    y1_bs_wait_n,
    SQH_FERROR, 
    PHD_FERROR, 
    PCX_FERROR, 
    SLC_FERROR,
    MAC_FERROR, 
    BLK_FERROR, 
    SQH_NERROR, 
    SQX_NERROR, 
    SQD_NERROR,
    GOP_NERROR, 
    PHD_NERROR, 
    PCX_NERROR, 
    PDX_NERROR, 
    CPY_NERROR,
    MAC_NERROR, 
    BLK_NERROR,
    SCD_PARAA, 
    SQH_PARAA, 
    SQX_PARAA, 
    SQD_PARAA, 
    USR_PARAA,
    GOP_PARAA, 
    PHD_PARAA, 
    PCX_PARAA, 
    PDX_PARAA, 
    CPY_PARAA,
    SLC_PARAA, 
    MAC_PARAA, 
    STREAM, 
    MAC_PARAD, 
    SCD_PARAD, 
    USR_PARAD, 
    PCX_PARAD, 
    PDX_PARAD,
    PHD_PARAD, 
    v_enderror,
    v_ferror_r, 
    v_nferror_r, 
    v_paramdata_r, 
    v_paramadr_r
);

input        clkdec;  
input        rstdec_x;
input        g_swrst_r_n; 
input        y1_bs_wait_n;  // Wait for user_data_address
input        SQH_FERROR;    // fatal error for sequence_header
input        PHD_FERROR;    // fatal error for picture_header
input        PCX_FERROR;    // fatal error for picture_coding_extension
input        SLC_FERROR;    // fatal error for slice
input        MAC_FERROR;    // fatal error for macroblock
input        BLK_FERROR;    // fatal error for block
input        SQH_NERROR;    // non-fatal error for sequence_header
input        SQX_NERROR;    // non-fatal error for sequence_extension
input        SQD_NERROR;    // non-fatal error for sequence_display_extension
input        GOP_NERROR;    // non-fatal error for group_of_picture_header
input        PHD_NERROR;    // non-fatal error for picture_header
input        PCX_NERROR;    // non-fatal error for picture_coding_extension
input        PDX_NERROR;    // non-fatal error for picture_display_extension
input        CPY_NERROR;    // non-fatal error for copyright_extension
input        MAC_NERROR;    // non-fatal error for macroblock
input        BLK_NERROR;    // non-fatal error for block
input  [7:0] SCD_PARAA;     // parameter_address for find start_code
input  [7:0] SQH_PARAA;     // parameter_address for sequence_header
input  [7:0] SQX_PARAA;     // parameter_address for sequence_extension
input  [7:0] SQD_PARAA;     // parameter_address for sequence_display_extension
input  [7:0] USR_PARAA;     // parameter_address for user_data
input  [7:0] GOP_PARAA;     // parameter_address for group_of_picture_header
input  [7:0] PHD_PARAA;     // parameter_address for picture_header
input  [7:0] PCX_PARAA;     // parameter_address for picture_coding_extension
input  [7:0] PDX_PARAA;     // parameter_address for picture_display_extension
input  [7:0] CPY_PARAA;     // parameter_address for copyright_extension
input  [7:0] SLC_PARAA;     // parameter_address for slice
input  [7:0] MAC_PARAA;     // parameter_address for macroblock
input [24:0] STREAM;        // bit stream(25bit)
input [17:0] MAC_PARAD;     // parameter_data for macroblock
input  [7:0] SCD_PARAD;     // parameter_data for find start_code
input  [7:0] USR_PARAD;     // parameter_data for user_data
input  [8:0] PCX_PARAD;     // parameter_data for picture_coding_extension
input  [1:0] PDX_PARAD;     // parameter_data for picture_display_extension
input  [2:0] PHD_PARAD;     // parameter_data for picture_header
input  v_enderror;        // end-of-macroblock error 

output        v_ferror_r;    // fatal error
output        v_nferror_r;   // non_fatal error
output [24:0] v_paramdata_r; // parameter_data(25bit)
output  [7:0] v_paramadr_r;  // parameter_address(8bit)

reg v_ferror_r;  //register
reg v_nferror_r;  //register
reg [24:0] v_paramdata_r;  //register
reg [7:0] v_paramadr_r;  //register
reg [7:0] v_usrdat;  //register

wire v_allferror_r;    // fatal error(all)
wire v_allnerror_r;    // non-fatal error(all)
wire [7:0] v_allparamadr_r;  // pamameter_address(all)
wire [7:0] v_selparamadr_r;  // parameter_address(for select data)
wire [24:0] v_allparamdata_r; // parameter_data(all)

assign v_allferror_r = SQH_FERROR | PHD_FERROR | 
                        PCX_FERROR | SLC_FERROR | MAC_FERROR |
                        BLK_FERROR | v_enderror; // 2004.3.5 

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin  
        v_ferror_r <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_ferror_r <= 1'b0;
          end
        else
          begin
            v_ferror_r <= v_allferror_r;
          end
      end 
  end

assign v_allnerror_r = SQH_NERROR | SQX_NERROR | SQD_NERROR |
                        GOP_NERROR | PHD_NERROR | PCX_NERROR |
                        PDX_NERROR | CPY_NERROR | MAC_NERROR |
                        BLK_NERROR;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        v_nferror_r <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_nferror_r <= 1'b0;
          end
        else
          begin
            v_nferror_r <= v_allnerror_r;
          end
      end
  end

always @(y1_bs_wait_n or USR_PARAA)
  begin
    if(y1_bs_wait_n == 1'b0) 
      begin
        v_usrdat = 8'hFF;   
      end
    else
      begin
        v_usrdat = USR_PARAA; 
      end
  end

assign v_allparamadr_r = SCD_PARAA & SQH_PARAA & SQX_PARAA & 
                          SQD_PARAA & v_usrdat & GOP_PARAA & 
                          PHD_PARAA & PCX_PARAA & PDX_PARAA &
                          CPY_PARAA & SLC_PARAA & MAC_PARAA;

assign v_selparamadr_r = SCD_PARAA & SQH_PARAA & SQX_PARAA &
                          SQD_PARAA & USR_PARAA & GOP_PARAA &
                          PHD_PARAA & PCX_PARAA & PDX_PARAA &
                          CPY_PARAA & SLC_PARAA & MAC_PARAA;


assign v_allparamdata_r = {MAC_PARAD,7'h00} | {SCD_PARAD,17'h00000} |
                            {USR_PARAD,17'h00000}|
                            {PCX_PARAD,16'h0000} | {PDX_PARAD,23'h000000} |
                            {PHD_PARAD,22'h000000}; 

                           
always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_paramadr_r <= 8'hFF;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_paramadr_r <= 8'hFF;
          end
        else
          begin
            v_paramadr_r <= v_allparamadr_r;
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_paramdata_r <= 25'h000000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_paramdata_r <= 25'h0000000;
          end
        else
          begin
            case(v_selparamadr_r)
              8'h0C : // slice_vertical_position
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h31 : // picture_coding_type
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h3E:// number_of_frame_centre_offsets
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h3F:// MPEG-1
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h45:// picture_structure
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h46:// top_field_first .... progressive_frame
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h50:// macroblock_address_increment
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h51:// macroblock_type
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h52:// frame_motion_type, field_motion_type
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h53:// dct_type 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h54:// quantiser_scale_code
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h55:// coded_block_pattern_420
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h60:// motion_vertical_field_select[0][0]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h61:// motion_code[0][0][0], motion_horizontal_forward_code
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h62:// motion_residual[0][0][0], motion_horizontal_forward_r
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h63:// dmvector[0]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h64:// motion_code[0][0][1], motion_vertical_forward_code
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h65:// motion_residual[0][0][1], motion_vertical_forward_r
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h66:// dmvector[1]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h68:// motion_vertical_field_select[0][1]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h69:// motion_code[0][1][0], motion_horizontal_backward_code
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h6a:// motion_residual[0][1][0], motion_horizontal_backward_r
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h6c:// motion_code[0][1][1], motion_horizontal_backward_code
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h6d:// motion_residual[0][1][1], motion_horizontal_backward_r
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h70:// motion_vertical_field_select[1][0]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h71:// motion_code[1][0][0] 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h72:// motion_residual[1][0][0]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h74:// motion_code[1][0][1] 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h75:// motion_residual[1][0][1] 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h78:// motion_vertical_field_select[1][1] 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h79:// motion_code[1][1][0]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h7a:// motion_residual[1][1][0]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h7c:// motion_code[1][1][1]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h7d:// motion_residual[1][1][1]
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h80:// user_data_start_code, user_data(0) 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h82:// user_data_start_code, user_data(1) 
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h88:// user_data_start_code, user_data(2)
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              8'h8a:// user_data_start_code, ATSC_data
                begin
                  v_paramdata_r <= v_allparamdata_r;
                end
              default:
                begin
                  v_paramdata_r <= STREAM;
                end
            endcase
          end
      end
  end

endmodule


