// ----------------------------------------------
// File: vld_motvec.v
// Module: vld_motvec
// Function:generate motion_vector from VLD
// ----------------------------------------------

module vld_motvec(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n,
    v_slicestart_r_s,
    c_mbpl_skpmb_r_s,
    v_mbhend_r_s,
    v_paramadr_r,
    v_paramdata_r,
    v_mbmot_type_r,
    c_mbpl_vld_r_s,
    v_motion_type_r,
    v_fstfwdvech_r,
    v_fstfwdvecv_r,
    v_fstbwdvech_r,
    v_fstbwdvecv_r,
    v_sndfwdvech_r,
    v_sndfwdvecv_r,
    v_sndbwdvech_r,
    v_sndbwdvecv_r,
    v_mode_mpeg1
);

input clkdec;              // VLD clock
input rstdec_x;            // Async reset
input g_swrst_r_n;           // Sync reset
input v_slicestart_r_s;      // start decode slice
input c_mbpl_skpmb_r_s;      // skipped MB plus
input v_mbhend_r_s;          // start generate motion vector
input [7:0] v_paramadr_r;    // parameter address(8bit)
input [24:17] v_paramdata_r; // parameter data(8bit)
input [1:0] v_mbmot_type_r;  // motion_type 
input c_mbpl_vld_r_s;        // start plus for MB decode

output  [1:0] v_motion_type_r;// motion_type
output [12:0] v_fstfwdvech_r; // first forward horizontal vector
output  [8:0] v_fstfwdvecv_r; // first forward vertical vector
output [12:0] v_fstbwdvech_r; // first backward horizontal vector
output  [8:0] v_fstbwdvecv_r; // first backward vertical vector
output [12:0] v_sndfwdvech_r; // second forward horizontal vector
output  [8:0] v_sndfwdvecv_r; // second forward vertical vector
output [12:0] v_sndbwdvech_r; // second backward horizontal vector
output  [8:0] v_sndbwdvecv_r; // second backward horizontal vector
input         v_mode_mpeg1;
 
wire [1:0] v_motion_type_r; // motion_type
wire [12:0] v_fstfwdvech_r; // first forward horizontal vector
wire [8:0] v_fstfwdvecv_r;  // first forward vertical vector
wire [12:0] v_fstbwdvech_r; // first backward horizontal vector
wire [8:0] v_fstbwdvecv_r;  // first backward vertical vector
wire [12:0] v_sndfwdvech_r; // second forward horizontal vector
wire [8:0] v_sndfwdvecv_r;  // second forward vertical vector
wire [12:0] v_sndbwdvech_r; // second backward horizontal vector
wire [8:0] v_sndbwdvecv_r;  // second backward horizontal vector

reg v_mpeg1; //1:MPEG-1, 0:MPEG-2 
reg [2:0] picture_coding_type; //011:I-pic,010:P-pic,011:B-pic,100:D-pic 
reg full_pel_forward_vector_r; // for MPEG-1
reg [2:0] forward_f_code; // for MPEG-1
reg full_pel_backward_vector_r; // for MPEG-1
reg [2:0] backward_f_code; // for MPEG-1
reg [3:0] forward_horizontal_f_code; // for MPEG-2
reg [3:0] forward_vertical_f_code; // for MPEG-2
reg [3:0] backward_horizontal_f_code; // for MPEG-2
reg [3:0] backward_vertical_f_code; // for MPEG-2
reg [1:0] picture_structure; //01:TopField, 10:BottomField, 11:Framepicture
reg frame_pred_frame_dct_r; // 1:frame-DCT 
reg concealment_motion_vectors_r; // 1:intra-MB
reg [2:0] macroblock_type; // [2]: macroblock_motion_forward,
                            // [1]: macroblock_motion_backward,
                            // [0]: macroblock_intra
reg [5:0] motion_code_000; // motion_code[0][0][0] for MPEG-2
reg [5:0] motion_code_001; // motion_code[0][0][1] for MPEG-2
reg [5:0] motion_code_010; // motion_code[0][1][0] for MPEG-2
reg [5:0] motion_code_011; // motion_code[0][1][1] for MPEG-2
reg [5:0] motion_code_100; // motion_code[1][0][0] for MPEG-2
reg [5:0] motion_code_101; // motion_code[1][0][1] for MPEG-2
reg [5:0] motion_code_110; // motion_code[1][1][0] for MPEG-2
reg [5:0] motion_code_111; // motion_code[1][1][1] for MPEG-2
reg [7:0] motion_residual_000; // motion_residual[0][0][0] for MPEG-2
reg [7:0] motion_residual_001; // motion_residual[0][0][1] for MPEG-2
reg [7:0] motion_residual_010; // motion_residual[0][1][0] for MPEG-2
reg [7:0] motion_residual_011; // motion_residual[0][1][1] for MPEG-2
reg [7:0] motion_residual_100; // motion_residual[1][0][0] for MPEG-2
reg [7:0] motion_residual_101; // motion_residual[1][0][1] for MPEG-2
reg [7:0] motion_residual_110; // motion_residual[1][1][0] for MPEG-2
reg [7:0] motion_residual_111; // motion_residual[1][1][1] for MPEG-2
reg [3:0] f_code_1;           //MPEG1 : forward_f_code[2:0],
                              //MPEG2 : forward_horizontal_f_code[3:0]
reg [3:0] f_code_2;           //MPEG1 : forward_f_code[2:0],
                              //MPEG2 : forward_vertical_f_code[3:0]
reg [3:0] f_code_3;           //MPEG1 : backward_f_code[2:0],
                              //MPEG2 : backward_horizontal_f_code[3:0]
reg [3:0] f_code_4;           //MPEG1 : backward_f_code[2:0],
                              //MPEG2 : backward_verical_f_code[3:0]

reg [1:0] v_mv_format; // motion_type

wire [12:0] v_selpmv_1; //
reg  [12:0] v_selpmv_2; //
wire [12:0] v_selpmv_3; //
reg  [12:0] v_selpmv_4; //
wire [12:0] v_selpmv_5; //
reg  [12:0] v_selpmv_6; //
wire [12:0] v_selpmv_7; //
reg  [12:0] v_selpmv_8; //
wire [12:0] v_pmv_1;    //
reg  [12:0] v_pmv_2; //
wire [12:0] v_pmv_3; //
reg  [12:0] v_pmv_4; //
wire [12:0] v_pmv_5; //
reg  [12:0] v_pmv_6; //
wire [12:0] v_pmv_7; //
reg  [12:0] v_pmv_8; //
wire [12:0] v_pmv_b1; //
wire [12:0] v_pmv_b2; //
wire [12:0] v_pmv_b3; //
wire [12:0] v_pmv_b4; //
wire [12:0] v_pmv_b5; //
wire [12:0] v_pmv_b6; //
wire [12:0] v_pmv_b7; //
wire [12:0] v_pmv_b8; //

wire [12:0] v_fstfwdvech; // first forward horizontal vector
wire [12:0] v_fstfwdvecv;  // first forward vertical vector
wire [12:0] v_fstbwdvech; // first backward horizontal vector
wire [12:0] v_fstbwdvecv;  // first backward vertical vector
wire [12:0] v_sndfwdvech; // second forward horizontal vector
wire [12:0] v_sndfwdvecv;  // second forward vertical vector
wire [12:0] v_sndbwdvech; // second backward horizontal vector
wire [12:0] v_sndbwdvecv;  // second backward horizontal vector
reg  [12:0] v_fstfwdvech_bb_r; // first forward horizontal vector
reg  [12:0] v_fstfwdvecv_bb_r;  // first forward vertical vector
reg  [12:0] v_fstbwdvech_bb_r; // first backward horizontal vector
reg  [12:0] v_fstbwdvecv_bb_r;  // first backward vertical vector
wire [12:0] v_sndfwdvech_bb_r; // second forward horizontal vector
wire [12:0] v_sndfwdvecv_bb_r;  // second forward vertical vector
wire [12:0] v_sndbwdvech_bb_r; // second backward horizontal vector
wire [12:0] v_sndbwdvecv_bb_r;  // second backward horizontal vector

reg [1:0] v_mbhend_ff_r_s;     // end-deocde
reg [1:0] v_mbpl_skpmb_ff_r_s; // skipped plus

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin 
        v_mv_format <= 2'b00;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_mv_format <= 2'b00;
          end
        else
          begin
            if(v_mbhend_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1)
              begin
                v_mv_format <= v_mbmot_type_r;
              end
            else
              begin
                v_mv_format <= v_mv_format;
              end
          end
      end
  end

assign v_motion_type_r = v_mv_format;

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_mpeg1 <= 1'b0; 
      end
    else
      begin
        if(v_mode_mpeg1)
            v_mpeg1 <= 1'b1; 
        else if(g_swrst_r_n == 1'b0) 
            v_mpeg1 <= 1'b0; 
        else
          begin
            case(v_paramadr_r)
              8'h3f :
                begin
                  v_mpeg1 <= v_paramdata_r[24]; 
                end
              default :
                begin
                  v_mpeg1 <= v_mpeg1; 
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        picture_coding_type <= 3'b000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            picture_coding_type <= 3'b000;
          end
        else
          begin
            case(v_paramadr_r)
              8'h31 :
                begin
                  picture_coding_type <= v_paramdata_r[24:22];
                end
              default :
                begin
                  picture_coding_type <= picture_coding_type;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        full_pel_forward_vector_r <= 1'b0; 
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            full_pel_forward_vector_r <= 1'b0; 
          end
        else
          begin
            case(v_paramadr_r)
              8'h33 :
                begin
                  full_pel_forward_vector_r <= v_paramdata_r[24]; 
                end
              default :
                begin
                  full_pel_forward_vector_r <= full_pel_forward_vector_r ^ frame_pred_frame_dct_r;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        forward_f_code  <= 3'b000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            forward_f_code <= 3'b000;
          end
        else
          begin
            case(v_paramadr_r)
              8'h34 :
                begin
                  forward_f_code <= v_paramdata_r[24:22];
                end
              default :
                begin
                  forward_f_code <= forward_f_code;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        full_pel_backward_vector_r <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            full_pel_backward_vector_r <= 1'b0;
          end
        else
          begin
            case(v_paramadr_r)
              8'h35 :
                begin
                  full_pel_backward_vector_r <= v_paramdata_r[24];
                end
              default :
                begin
                  full_pel_backward_vector_r <= full_pel_backward_vector_r ^ frame_pred_frame_dct_r;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        backward_f_code <= 3'b000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            backward_f_code <= 3'b000;
          end
        else
          begin
            case(v_paramadr_r)
              8'h36 :
                begin
                  backward_f_code <= v_paramdata_r[24:22];
                end
              default :
                begin
                  backward_f_code <= backward_f_code;
                end
            endcase
          end
      end
  end
 
always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        forward_horizontal_f_code <= 4'h0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            forward_horizontal_f_code <= 4'h0;
          end
        else
          begin
            case(v_paramadr_r)
              8'h40 :
                begin
                  forward_horizontal_f_code <= v_paramdata_r[24:21];
                end
              default :
                begin
                  forward_horizontal_f_code <= forward_horizontal_f_code;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        forward_vertical_f_code <= 4'h0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            forward_vertical_f_code <= 4'h0;
          end
        else
          begin
            case(v_paramadr_r)
              8'h41 :
                begin
                  forward_vertical_f_code <= v_paramdata_r[24:21];
                end
              default :
                begin
                  forward_vertical_f_code <= forward_vertical_f_code;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        backward_horizontal_f_code <= 4'h0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            backward_horizontal_f_code <= 4'h0;
          end
        else
          begin
            case(v_paramadr_r)
              8'h42 :
                begin
                  backward_horizontal_f_code <= v_paramdata_r[24:21];
                end
              default :
                begin
                  backward_horizontal_f_code <= backward_horizontal_f_code;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0)
      begin
        backward_vertical_f_code <= 4'h0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            backward_vertical_f_code <= 4'h0;
          end
        else
          begin
            case(v_paramadr_r)
              8'h43 :
                begin
                  backward_vertical_f_code <= v_paramdata_r[24:21];
                end
              default :
                begin
                  backward_vertical_f_code <= backward_vertical_f_code;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        picture_structure <= 2'b00;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            picture_structure <= 2'b00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h45 :
                begin
                  picture_structure <= v_paramdata_r[24:23];
                end
              default :
                begin
                  picture_structure <= picture_structure;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        frame_pred_frame_dct_r <= 1'b0;
        concealment_motion_vectors_r <= 1'b0;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            frame_pred_frame_dct_r <= 1'b0;
            concealment_motion_vectors_r <= 1'b0;
          end
        else
          begin
            case(v_paramadr_r)
              8'h46 :
                begin
                  frame_pred_frame_dct_r <= v_paramdata_r[23];
                  concealment_motion_vectors_r <= v_paramdata_r[22];
                end
              default :
                begin
                  frame_pred_frame_dct_r <= frame_pred_frame_dct_r;
                  concealment_motion_vectors_r <= concealment_motion_vectors_r;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        macroblock_type <= 3'b000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            macroblock_type <= 3'b000;
          end
        else
          begin
            case(v_paramadr_r)
              8'h51 :
                begin
                  macroblock_type <= v_paramdata_r[24:22];
                end
              default :
                begin
                  macroblock_type <= macroblock_type;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_000  <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || // SW reset
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_000 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h61 :
                begin
                  motion_code_000 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_000 <= motion_code_000;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_001 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_001 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h64 :
                begin
                  motion_code_001 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_001 <= motion_code_001;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_010 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_010 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h69 :
                begin
                  motion_code_010 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_010 <= motion_code_010;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_011 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_011 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h6c :
                begin
                  motion_code_011 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_011 <= motion_code_011;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_100 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_100 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h71 :
                begin
                  motion_code_100 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_100 <= motion_code_100;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_101 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_101 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h74 :
                begin
                  motion_code_101 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_101 <= motion_code_101;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_110 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_110 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h79 :
                begin
                  motion_code_110 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_110 <= motion_code_110;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_code_111 <= 6'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_code_111 <= 6'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h7c :
                begin
                  motion_code_111 <= v_paramdata_r[24:19];
                end
              default :
                begin
                  motion_code_111 <= motion_code_111;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_000 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_000 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h62 :
                begin
                  motion_residual_000 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_000 <= motion_residual_000;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_001 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_001 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h65 :
                begin
                  motion_residual_001 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_001 <= motion_residual_001;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_010 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_010 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h6a :
                begin
                  motion_residual_010 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_010 <= motion_residual_010;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_011 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_011 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h6d :
                begin
                  motion_residual_011 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_011 <= motion_residual_011;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_100 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_100 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h72 :
                begin
                  motion_residual_100 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_100 <= motion_residual_100;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_101 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_101 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h75 :
                begin
                  motion_residual_101 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_101 <= motion_residual_101;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_110 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_110 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h7a :
                begin
                  motion_residual_110 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_110 <= motion_residual_110;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        motion_residual_111 <= 8'h00;
      end
    else
      begin
        if((g_swrst_r_n == 1'b0) || 
            (c_mbpl_vld_r_s == 1'b1 || c_mbpl_skpmb_r_s == 1'b1))
          begin
            motion_residual_111 <= 8'h00;
          end
        else
          begin
            case(v_paramadr_r)
              8'h7d :
                begin
                  motion_residual_111 <= v_paramdata_r[24:17];
                end
              default :
                begin
                  motion_residual_111 <= motion_residual_111;
                end
            endcase
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_mbhend_ff_r_s <= 2'b00;
        v_mbpl_skpmb_ff_r_s <= 2'b00;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_mbhend_ff_r_s <= 2'b00;
            v_mbpl_skpmb_ff_r_s <= 2'b00;
          end
        else
          begin
            v_mbhend_ff_r_s <= {v_mbhend_ff_r_s[0],v_mbhend_r_s};
            v_mbpl_skpmb_ff_r_s 
                      <= {v_mbpl_skpmb_ff_r_s[0],c_mbpl_skpmb_r_s};
          end
      end
  end

vld_genpmv vld_genpmv(
         .clkdec(clkdec), 
         .rstdec_x(rstdec_x), 
         .g_swrst_r_n(g_swrst_r_n),
         .v_slicestart_r_s(v_slicestart_r_s),
         .v_mbmot_type_r(v_mbmot_type_r), .v_mpeg1(v_mpeg1),
         .v_picture_coding_type(picture_coding_type),
         .v_concealment_motion_vectors(concealment_motion_vectors_r), 
         .v_macroblock_type(macroblock_type), 
         .v_picture_structure(picture_structure),
         .v_selpmv_1(v_selpmv_1), .v_selpmv_2(v_selpmv_2), 
         .v_selpmv_3(v_selpmv_3), .v_selpmv_4(v_selpmv_4),
         .v_selpmv_5(v_selpmv_5), .v_selpmv_6(v_selpmv_6), 
         .v_selpmv_7(v_selpmv_7), .v_selpmv_8(v_selpmv_8),
         .v_mbhend_ff_r_s(v_mbhend_ff_r_s[1]), 
         .v_mbpl_skpmb_r_s(v_mbpl_skpmb_ff_r_s[1]),
         .v_oselpmv_1(v_pmv_b1), .v_oselpmv_2(v_pmv_b2), 
         .v_oselpmv_3(v_pmv_b3), .v_oselpmv_4(v_pmv_b4),
         .v_oselpmv_5(v_pmv_b5), .v_oselpmv_6(v_pmv_b6), 
         .v_oselpmv_7(v_pmv_b7), .v_oselpmv_8(v_pmv_b8)
);

vld_genvec vld_genvec_1(
                        .v_f_code(f_code_1),
                        .v_motion_code(motion_code_000),
                        .v_motion_residual(motion_residual_000),
                        .v_inpmv(v_pmv_1),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_fstfwdvech)
);

vld_genvec vld_genvec_2(
                        .v_f_code(f_code_2),
                        .v_motion_code(motion_code_001),
                        .v_motion_residual(motion_residual_001),
                        .v_inpmv(v_pmv_2),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_fstfwdvecv)
);

vld_genvec vld_genvec_3(
                        .v_f_code(f_code_3),
                        .v_motion_code(motion_code_010),
                        .v_motion_residual(motion_residual_010),
                        .v_inpmv(v_pmv_3),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_fstbwdvech)
);

vld_genvec vld_genvec_4(
                        .v_f_code(f_code_4),
                        .v_motion_code(motion_code_011),
                        .v_motion_residual(motion_residual_011),
                        .v_inpmv(v_pmv_4),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_fstbwdvecv)
);

vld_genvec vld_genvec_5(
                        .v_f_code(forward_horizontal_f_code), 
                        .v_motion_code(motion_code_100), 
                        .v_motion_residual(motion_residual_100), 
                        .v_inpmv(v_pmv_5),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_sndfwdvech)
);

vld_genvec vld_genvec_6(
                        .v_f_code(forward_vertical_f_code), 
                        .v_motion_code(motion_code_101), 
                        .v_motion_residual(motion_residual_101), 
                        .v_inpmv(v_pmv_6),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_sndfwdvecv)
);

vld_genvec vld_genvec_7(
                        .v_f_code(backward_horizontal_f_code), 
                        .v_motion_code(motion_code_110), 
                        .v_motion_residual(motion_residual_110), 
                        .v_inpmv(v_pmv_7),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_sndbwdvech)
);

vld_genvec vld_genvec_8(
                        .v_f_code(backward_vertical_f_code), 
                        .v_motion_code(motion_code_111), 
                        .v_motion_residual(motion_residual_111), 
                        .v_inpmv(v_pmv_8),
                        .clkdec(clkdec),
                        .rstdec_x(rstdec_x),
                        .g_swrst_r_n(g_swrst_r_n),
                        .v_vector(v_sndbwdvecv)
);

vld_outvec vld_outvec(
                      .clkdec(clkdec), 
                      .rstdec_x(rstdec_x), 
                      .g_swrst_r_n(g_swrst_r_n),
                      .v_mbhend_ff_r_s(v_mbhend_ff_r_s[1]), 
                      .v_mbpl_skpmb_r_s(v_mbpl_skpmb_ff_r_s[1]),
                      .v_picture_coding_type(picture_coding_type),
                      .v_pmv_1(v_pmv_1), .v_pmv_2(v_pmv_2[8:0]), 
                      .v_pmv_3(v_pmv_3), .v_pmv_4(v_pmv_4[8:0]),
                      .v_pmv_5(v_pmv_5), .v_pmv_6(v_pmv_6[8:0]), 
                      .v_pmv_7(v_pmv_7), .v_pmv_8(v_pmv_8[8:0]),
                      .v_fstfwdvech_b_r(v_fstfwdvech_bb_r), 
                      .v_fstfwdvecv_b_r(v_fstfwdvecv_bb_r[8:0]),
                      .v_fstbwdvech_b_r(v_fstbwdvech_bb_r), 
                      .v_fstbwdvecv_b_r(v_fstbwdvecv_bb_r[8:0]),
                      .v_sndfwdvech_b_r(v_sndfwdvech_bb_r), 
                      .v_sndfwdvecv_b_r(v_sndfwdvecv_bb_r[8:0]),
                      .v_sndbwdvech_b_r(v_sndbwdvech_bb_r), 
                      .v_sndbwdvecv_b_r(v_sndbwdvecv_bb_r[8:0]),
                      .v_ofstfwdvech_r(v_fstfwdvech_r),
                      .v_ofstfwdvecv_r(v_fstfwdvecv_r),
                      .v_ofstbwdvech_r(v_fstbwdvech_r),
                      .v_ofstbwdvecv_r(v_fstbwdvecv_r),
                      .v_osndfwdvech_r(v_sndfwdvech_r),
                      .v_osndfwdvecv_r(v_sndfwdvecv_r),
                      .v_osndbwdvech_r(v_sndbwdvech_r),
                      .v_osndbwdvecv_r(v_sndbwdvecv_r)
);

always @(v_mpeg1 or forward_f_code or forward_horizontal_f_code) 
  begin
   case(v_mpeg1) 
      1'b1    : f_code_1 = {1'b0, forward_f_code};
      default : f_code_1 = forward_horizontal_f_code;
    endcase
  end

always @(v_mpeg1 or forward_f_code or forward_vertical_f_code)
  begin
    case(v_mpeg1) 
      1'b1    : f_code_2 = {1'b0, forward_f_code};
      default : f_code_2 = forward_vertical_f_code;
    endcase
  end

always @(v_mpeg1 or backward_f_code or backward_horizontal_f_code)
  begin
    case(v_mpeg1) 
      1'b1    : f_code_3 = {1'b0, backward_f_code};
      default : f_code_3 = backward_horizontal_f_code;
    endcase
  end

always @(v_mpeg1 or backward_f_code or backward_vertical_f_code)
  begin
    case(v_mpeg1)
      1'b1    : f_code_4 = {1'b0, backward_f_code};
      default : f_code_4 = backward_vertical_f_code;
    endcase
  end

assign v_selpmv_1 = v_fstfwdvech;
assign v_selpmv_3 = v_fstbwdvech;
assign v_selpmv_5 = v_sndfwdvech;
assign v_selpmv_7 = v_sndbwdvech;

always @(v_mpeg1 or v_mv_format or picture_structure or v_sndfwdvecv)
 begin
    if(v_mpeg1 == 1'b0 &&  
        (v_mv_format == 2'b01  || v_mv_format == 2'b11) &&  
          picture_structure == 2'b11) 
      begin
        v_selpmv_6 = v_sndfwdvecv << 1;
      end
    else
      begin
        v_selpmv_6 = v_sndfwdvecv;
      end
  end

always @(v_mpeg1 or v_mv_format or picture_structure or v_sndbwdvecv)
  begin
    if(v_mpeg1 == 1'b0 && 
        (v_mv_format == 2'b01  || v_mv_format == 2'b11) && 
          picture_structure == 2'b11)
      begin
        v_selpmv_8 = v_sndbwdvecv << 1;
      end
    else
      begin
        v_selpmv_8 = v_sndbwdvecv;
      end
  end

always @(v_mpeg1 or v_mv_format or picture_structure or v_fstfwdvecv)
  begin
    if(v_mpeg1 == 1'b0 &&    
        (v_mv_format == 2'b01  || v_mv_format == 2'b11) &&   
          picture_structure == 2'b11) 
      begin
        v_selpmv_2 = v_fstfwdvecv << 1;
      end
    else
      begin
        v_selpmv_2 = v_fstfwdvecv;
      end
  end

always @(v_mpeg1 or v_mv_format or picture_structure or v_fstbwdvecv)
  begin
    if(v_mpeg1 == 1'b0 &&  
        (v_mv_format == 2'b01  || v_mv_format == 2'b11) &&
          picture_structure == 2'b11)   
      begin
        v_selpmv_4 = v_fstbwdvecv << 1;
      end
    else
      begin
        v_selpmv_4 = v_fstbwdvecv;
      end
  end

assign v_pmv_1 = v_pmv_b1;
assign v_pmv_3 = v_pmv_b3;
assign v_pmv_5 = v_pmv_b5;
assign v_pmv_7 = v_pmv_b7;

always @(v_mpeg1 or v_mv_format or picture_structure or v_pmv_b2) 
  begin
    if(v_mpeg1 == 1'b0 && 
        (v_mv_format == 2'b01 || v_mv_format == 2'b11)   
      &&   picture_structure == 2'b11)
      begin
        v_pmv_2 = v_pmv_b2 >> 1;
      end
    else
      begin
        v_pmv_2 = v_pmv_b2;
      end
  end

always @(v_mpeg1 or v_mv_format or picture_structure or v_pmv_b4)
  begin
    if(v_mpeg1 == 1'b0 &&    
        (v_mv_format == 2'b01 || v_mv_format == 2'b11)  
      &&   picture_structure == 2'b11) 
      begin
        v_pmv_4 = v_pmv_b4 >> 1;
      end
    else
      begin
        v_pmv_4 = v_pmv_b4;
      end
  end

always @(v_mpeg1 or v_mv_format or picture_structure or v_pmv_b6) 
  begin
    if(v_mpeg1 == 1'b0 &&       
      (v_mv_format == 2'b01 || v_mv_format == 2'b11)   
      &&   picture_structure == 2'b11) 
      begin
        v_pmv_6 = v_pmv_b6 >> 1;
      end
    else
      begin
        v_pmv_6 = v_pmv_b6;
      end
  end

always @(v_mpeg1 or v_mv_format or picture_structure or v_pmv_b8) 
  begin
    if(v_mpeg1 == 1'b0 &&             
        (v_mv_format == 2'b01 || v_mv_format == 2'b11)   
      &&    picture_structure == 2'b11)  
      begin
        v_pmv_8 = v_pmv_b8 >> 1;
      end
    else
      begin
        v_pmv_8 = v_pmv_b8;
      end
  end

always @(v_mpeg1 or full_pel_forward_vector_r or v_fstfwdvech) 
  begin
     if(v_mpeg1 == 1'b1 && full_pel_forward_vector_r == 1'b1) 
      begin                            
         v_fstfwdvech_bb_r = v_fstfwdvech << 1;  
      end
    else
      begin
        v_fstfwdvech_bb_r = v_fstfwdvech;
      end
  end

always @(v_mpeg1 or full_pel_forward_vector_r or v_fstfwdvecv) 
  begin
    if(v_mpeg1 == 1'b1 && full_pel_forward_vector_r == 1'b1)  
      begin  
        v_fstfwdvecv_bb_r = v_fstfwdvecv << 1;
      end
    else
      begin
        v_fstfwdvecv_bb_r = v_fstfwdvecv;
      end
  end

always @(v_mpeg1 or full_pel_backward_vector_r or v_fstbwdvech)  
  begin
    if(v_mpeg1 == 1'b1 && full_pel_backward_vector_r == 1'b1)  
      begin
        v_fstbwdvech_bb_r = v_fstbwdvech << 1;
      end
    else
      begin
        v_fstbwdvech_bb_r = v_fstbwdvech;
      end
  end

always @(v_mpeg1 or full_pel_backward_vector_r or v_fstbwdvecv)  
  begin
    if(v_mpeg1 == 1'b1 && full_pel_backward_vector_r == 1'b1)  
      begin
        v_fstbwdvecv_bb_r = v_fstbwdvecv << 1;
      end
    else
      begin
        v_fstbwdvecv_bb_r = v_fstbwdvecv;
      end
  end

assign v_sndfwdvech_bb_r = v_sndfwdvech;
assign v_sndfwdvecv_bb_r = v_sndfwdvecv;
assign v_sndbwdvech_bb_r = v_sndbwdvech;
assign v_sndbwdvecv_bb_r = v_sndbwdvecv;


endmodule

