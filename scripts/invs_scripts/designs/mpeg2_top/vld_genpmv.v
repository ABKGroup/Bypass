// ----------------------------------------------
// File: vld_genpmv.v
// Module: vld_genpmv
// Function:generate motion_vector from VLD
// ----------------------------------------------

module vld_genpmv(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    v_slicestart_r_s,
    v_mbmot_type_r, 
    v_mpeg1, 
    v_picture_coding_type,       
    v_concealment_motion_vectors,
    v_macroblock_type, 
    v_picture_structure, 
    v_selpmv_1, 
    v_selpmv_2, 
    v_selpmv_3, 
    v_selpmv_4,
    v_selpmv_5, 
    v_selpmv_6, 
    v_selpmv_7, 
    v_selpmv_8,
    v_mbhend_ff_r_s, 
    v_mbpl_skpmb_r_s,
    v_oselpmv_1, 
    v_oselpmv_2, 
    v_oselpmv_3, 
    v_oselpmv_4,
    v_oselpmv_5, 
    v_oselpmv_6, 
    v_oselpmv_7, 
    v_oselpmv_8
);

input clkdec; // VLD clock
input rstdec_x; // Async reset
input g_swrst_r_n; // Sync reset
input v_slicestart_r_s; // start-decode for slice
input [1:0] v_mbmot_type_r; // motion_type 
input v_mpeg1; // 1:MPEG-1 0:MPEG-2
input [2:0] v_picture_coding_type; // 001:I,010:P,011:B,100:D 
input v_concealment_motion_vectors; // 1:intra-MB  2004.3.10
input [2:0] v_macroblock_type; //[2]:forward [1]:backward [0]:intra 
input [1:0] v_picture_structure; // 01,10:Field 11,(00):Frame 
input [12:0] v_selpmv_1; //
input [12:0] v_selpmv_2; //
input [12:0] v_selpmv_3; //
input [12:0] v_selpmv_4; //
input [12:0] v_selpmv_5; //
input [12:0] v_selpmv_6; //
input [12:0] v_selpmv_7; //
input [12:0] v_selpmv_8; //
input v_mbhend_ff_r_s; // output timing for PMV
input v_mbpl_skpmb_r_s; //
output [12:0] v_oselpmv_1; //
output [12:0] v_oselpmv_2; //
output [12:0] v_oselpmv_3; //
output [12:0] v_oselpmv_4; //
output [12:0] v_oselpmv_5; //
output [12:0] v_oselpmv_6; //
output [12:0] v_oselpmv_7; //
output [12:0] v_oselpmv_8; //

reg [12:0] v_oselpmv_1; //
reg [12:0] v_oselpmv_2; //
reg [12:0] v_oselpmv_3; //
reg [12:0] v_oselpmv_4; //
reg [12:0] v_oselpmv_5; //
reg [12:0] v_oselpmv_6; //
reg [12:0] v_oselpmv_7; //
reg [12:0] v_oselpmv_8; //
reg v_p_skp; // P-picture and Skipped MB
reg v_mp2_nonconceal_intra;// MPEG-2 and concealment=0 and intra MB
reg v_mp2_p_nonfwd_nonintra;// MPEG-2 and P-picture and fwd=0 and nonintra MB
reg v_mp1_p_nonfwd; // MPEG-1 and P-piture and fwd=0
reg v_mp1_b_intra; // MPEG-1 and B-picture and intra MB

wire v_reset0; // PMV reset condition signal
wire v_outtrg_s; // plus

always @(v_picture_coding_type or v_mbpl_skpmb_r_s) 
  begin
    if(v_picture_coding_type == 3'b010 && v_mbpl_skpmb_r_s == 1'b1)
      begin
        v_p_skp = 1'b1;
      end
    else
      begin
        v_p_skp = 1'b0;
      end
  end

assign v_outtrg_s = v_mbhend_ff_r_s ; 

always @(v_mpeg1 or v_concealment_motion_vectors or v_macroblock_type)
  begin
    if(v_mpeg1 == 1'b0 && v_concealment_motion_vectors == 1'b0 &&
        v_macroblock_type[0] == 1'b1)     
      begin
        v_mp2_nonconceal_intra = 1'b1;
      end
    else
      begin
        v_mp2_nonconceal_intra = 1'b0;
      end
  end

always @(v_mpeg1 or v_picture_coding_type or v_macroblock_type) 
  begin
    if(v_mpeg1 == 1'b0 && v_picture_coding_type == 3'b010 && 
        v_macroblock_type[2] == 1'b0 && v_macroblock_type[0] == 1'b0)
      begin
        v_mp2_p_nonfwd_nonintra = 1'b1;
      end
    else
      begin
        v_mp2_p_nonfwd_nonintra = 1'b0;
      end
  end

always @(v_mpeg1 or v_picture_coding_type or v_macroblock_type)
  begin
    if(v_mpeg1 == 1'b1 && v_picture_coding_type == 3'b010 && 
        v_macroblock_type[2] == 1'b0) 
      begin
        v_mp1_p_nonfwd = 1'b1;
      end
    else
      begin
        v_mp1_p_nonfwd = 1'b0;
      end
  end

always @(v_mpeg1 or v_picture_coding_type or v_macroblock_type)
  begin
    if(v_mpeg1 == 1'b1 && v_picture_coding_type == 3'b011 && 
        v_macroblock_type[0] == 1'b1) 
      begin
        v_mp1_b_intra = 1'b1;
      end
    else
      begin
        v_mp1_b_intra = 1'b0;
      end
  end

assign v_reset0 = v_slicestart_r_s | v_p_skp | v_mp2_nonconceal_intra
                  | v_mp2_p_nonfwd_nonintra | v_mp1_p_nonfwd
                  | v_mp1_b_intra ; 
                   
always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_oselpmv_1 <= 13'h0000;
        v_oselpmv_2 <= 13'h0000;
        v_oselpmv_3 <= 13'h0000;
        v_oselpmv_4 <= 13'h0000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0 || 
          v_reset0 == 1'b1 )     
          begin
            v_oselpmv_1 <= 13'h0000;
            v_oselpmv_2 <= 13'h0000;
            v_oselpmv_3 <= 13'h0000;
            v_oselpmv_4 <= 13'h0000;
          end
        else
          begin
            if((v_outtrg_s  == 1'b1) && v_mpeg1 == 1'b0) 
              begin          
                if(((v_picture_structure == 2'b11 
                        || v_picture_structure == 2'b00) 
                  && v_mbmot_type_r == 2'b10)    
                  || ((v_picture_structure == 2'b10 
                        || v_picture_structure == 2'b01) 
                  && v_mbmot_type_r == 2'b01))           
                  begin
                    case(v_macroblock_type) 
                      3'b000 : 
                        begin
                          v_oselpmv_1 <= 13'h0000;
                          v_oselpmv_2 <= 13'h0000;
                          v_oselpmv_3 <= 13'h0000;
                          v_oselpmv_4 <= 13'h0000;
                        end
                      default :
                        begin
                          v_oselpmv_1 <= v_selpmv_1;
                          v_oselpmv_2 <= v_selpmv_2;
                          v_oselpmv_3 <= v_selpmv_3;
                          v_oselpmv_4 <= v_selpmv_4;
                        end
                    endcase
                  end
                else
                  begin
                    v_oselpmv_1 <= v_selpmv_1;
                    v_oselpmv_2 <= v_selpmv_2;
                    v_oselpmv_3 <= v_selpmv_3;
                    v_oselpmv_4 <= v_selpmv_4;
                  end
              end
            else if(v_outtrg_s == 1'b1) 
              begin
                v_oselpmv_1 <= v_selpmv_1;
                v_oselpmv_2 <= v_selpmv_2;
                v_oselpmv_3 <= v_selpmv_3;
                v_oselpmv_4 <= v_selpmv_4;
              end
            else // hold    
              begin
                v_oselpmv_1 <= v_oselpmv_1;
                v_oselpmv_2 <= v_oselpmv_2;
                v_oselpmv_3 <= v_oselpmv_3;
                v_oselpmv_4 <= v_oselpmv_4;
              end
          end  
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_oselpmv_5 <= 13'h0000;
        v_oselpmv_6 <= 13'h0000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0 || 
          v_reset0 == 1'b1 )     
          begin
            v_oselpmv_5 <= 13'h0000;
            v_oselpmv_6 <= 13'h0000;
          end
        else
          begin
            if(v_outtrg_s == 1'b1 && v_mpeg1 == 1'b0)
              begin                                     
                if(v_picture_structure == 2'b11 
                    || v_picture_structure == 2'b00) 
                                                     
                  begin
                    if(v_mbmot_type_r == 2'b10)          
                      begin
                        case(v_macroblock_type) 
                          3'b001 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b011 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end 
                          3'b101 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b111 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b110 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b100 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b000 :
                            begin
                              v_oselpmv_5 <= 13'h0000;
                              v_oselpmv_6 <= 13'h0000;
                            end
                          default :
                            begin
                              v_oselpmv_5 <= v_selpmv_5;
                              v_oselpmv_6 <= v_selpmv_6;
                            end
                        endcase
                      end
                    else if(v_mbmot_type_r == 2'b11)       
                      begin
                        case(v_macroblock_type) 
                          3'b100 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end 
                          default :
                            begin
                              v_oselpmv_5 <= v_selpmv_5;
                              v_oselpmv_6 <= v_selpmv_6;
                            end
                        endcase
                      end
                    else
                      begin
                        v_oselpmv_5 <= v_selpmv_5;
                        v_oselpmv_6 <= v_selpmv_6;
                      end
                  end
                else if(v_picture_structure == 2'b10 || 
                    v_picture_structure == 2'b01)
                  begin
                    if(v_mbmot_type_r == 2'b01)          
                      begin
                        case(v_macroblock_type) 
                          3'b001 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b011 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b101 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b111 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b110 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b100 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          3'b000 :
                            begin
                              v_oselpmv_5 <= 13'h0000;
                              v_oselpmv_6 <= 13'h0000;
                            end
                          default :
                            begin
                              v_oselpmv_5 <= v_selpmv_5;
                              v_oselpmv_6 <= v_selpmv_6;
                            end
                        endcase
                      end
                    else if(v_mbmot_type_r == 2'b11)    
                      begin
                        case(v_macroblock_type) 
                          3'b100 :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                          default :
                            begin
                              v_oselpmv_5 <= v_selpmv_1;
                              v_oselpmv_6 <= v_selpmv_2;
                            end
                        endcase
                      end
                    else
                      begin
                        v_oselpmv_5 <= v_selpmv_5;
                        v_oselpmv_6 <= v_selpmv_6;
                      end
                  end
                else
                  begin
                    v_oselpmv_5 <= v_selpmv_5; 
                    v_oselpmv_6 <= v_selpmv_6;
                  end
              end
            else if(v_outtrg_s == 1'b1) 
              begin 
                v_oselpmv_5 <= v_selpmv_5;
                v_oselpmv_6 <= v_selpmv_6;
              end
            else
              begin
                v_oselpmv_5 <= v_oselpmv_5;
                v_oselpmv_6 <= v_oselpmv_6;
              end
          end
      end
  end 
 
always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_oselpmv_7 <= 13'h0000;
        v_oselpmv_8 <= 13'h0000;
      end
    else
      begin
        if(g_swrst_r_n == 1'b0 ||  
          v_reset0 == 1'b1 )     
          begin
            v_oselpmv_7 <= 13'h0000;
            v_oselpmv_8 <= 13'h0000;
          end
        else
          begin
            if(v_outtrg_s == 1'b1 && v_mpeg1 == 1'b0) 
              begin                    
                if(v_picture_structure == 2'b11 
                  || v_picture_structure == 2'b00)   
                                                      
                  begin
                    if(v_mbmot_type_r == 2'b10)          
                      begin
                        case(v_macroblock_type) 
                          3'b110 :
                            begin
                              v_oselpmv_7 <= v_selpmv_3;
                              v_oselpmv_8 <= v_selpmv_4;
                            end
                          3'b010 :
                            begin
                              v_oselpmv_7 <= v_selpmv_3;
                              v_oselpmv_8 <= v_selpmv_4;
                            end
                          3'b000 :
                            begin
                              v_oselpmv_7 <= 13'h0000;
                              v_oselpmv_8 <= 13'h0000;
                            end
                          default :
                            begin
                              v_oselpmv_7 <= v_selpmv_3;
                              v_oselpmv_8 <= v_selpmv_4;
                            end
                        endcase
                      end
                    else
                      begin
                        v_oselpmv_7 <= v_selpmv_3;
                        v_oselpmv_8 <= v_selpmv_4;
                      end
                  end
                else if(v_picture_structure == 2'b10 ||
                  v_picture_structure == 2'b01) 
                  begin
                    if(v_mbmot_type_r == 2'b01)       
                      begin
                        case(v_macroblock_type) 
                          3'b110 :
                            begin
                              v_oselpmv_7 <= v_selpmv_3;
                              v_oselpmv_8 <= v_selpmv_4;
                            end
                          3'b010 :
                            begin
                              v_oselpmv_7 <= v_selpmv_3;
                              v_oselpmv_8 <= v_selpmv_4;
                            end
                          3'b000 :
                            begin
                              v_oselpmv_7 <= 13'h0000;
                              v_oselpmv_8 <= 13'h0000;
                            end
                          default :
                            begin
                              v_oselpmv_7 <= v_selpmv_7;
                              v_oselpmv_8 <= v_selpmv_8;
                            end
                        endcase
                      end
                    else
                      begin
                        v_oselpmv_7 <= v_selpmv_7;
                        v_oselpmv_8 <= v_selpmv_8;
                      end
                  end
                else
                  begin
                    v_oselpmv_7 <= v_selpmv_7;
                    v_oselpmv_8 <= v_selpmv_8;
                  end
              end
            else if(v_outtrg_s == 1'b1) 
              begin
                v_oselpmv_7 <= v_selpmv_7;
                v_oselpmv_8 <= v_selpmv_8;
              end
            else
              begin
                v_oselpmv_7 <= v_oselpmv_7;
                v_oselpmv_8 <= v_oselpmv_8;
              end
          end
      end
  end


 
endmodule

