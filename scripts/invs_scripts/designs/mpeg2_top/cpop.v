// ----------------------------------------------
// File: cpop.v
// Module: cpop
// Function:
// ----------------------------------------------

module cpop (
    clkdec, 
    rstdec_x,
    c_pstr_r,            
    c_prgseq_r,          
    c_hsval_r,           
    c_vsval_r,           
    g_hs60p_r,           
    g_vs60p_r,           
    c_frate_r,           
    c_pic_codtyp_r,      
    c_mbtyp_2_r,         
    c_mbtyp_1_r,         
    c_mbtyp_0_r,         
    v_seqstrt_r,         
    v_picstrt_r,         
    v_slicestart_r,     
    v_mbadet_r,         
    c_mbpl_vld_r_s,     
    c_skpmb_r,          
    n_pic_codtyp_reffld1_r,
    n_pic_codtyp_reffld2_r,
    n_pic_codtyp_reffld3_r,
    n_pic_codtyp_reffld4_r,
    c_fldsel1_r,           
    c_fldsel2_r,           
    c_fldsel3_r,           
    c_fldsel4_r,           
    c_qsc_r,               
    c_qst_r,               
    g_mbc_r,               
    g_mbc_en_r,            
    p_hdtvh_r,           
    g_fcyc_en_r,           
    g_fcyc_r,              
    c_pcth_mb_r,           
    c_pctv_mb_r,           
    c_auto_rpt_md_r,       
    c_fldpl_cycl_r,        
    c_pred_forward_r,      
    c_pred_backward_r,     
    c_seqhdet_r,           
    c_phdet_r,             
    c_shdet_r,             
    c_mbaidet_s,           
    c_fldsel1_fix1_r,      
    c_fldsel2_fix1_r,      
    c_fldsel3_fix1_r,      
    c_fldsel4_fix1_r,    
    c_qscale_r,          
    c_mbpl_cycl_r        
  );

    input         clkdec;      
    input         rstdec_x;    
    input [1:0]   c_pstr_r;      
    input         c_prgseq_r;
    input [11:0]  c_hsval_r;     
    input [11:0]  c_vsval_r;     
    input [6:0]  g_hs60p_r;      
    input [6:0]  g_vs60p_r;      
    input [2:0]   c_frate_r;     
    input [2:0]   c_pic_codtyp_r;
    input         c_mbtyp_2_r;   
    input         c_mbtyp_1_r;   
    input         c_mbtyp_0_r;   
    input         v_seqstrt_r;   
    input         v_picstrt_r;   
    input         v_slicestart_r;
    input         v_mbadet_r;    
    input         c_mbpl_vld_r_s;
    input         c_skpmb_r;     
    input [2:0]   n_pic_codtyp_reffld1_r;
    input [2:0]   n_pic_codtyp_reffld2_r;
    input [2:0]   n_pic_codtyp_reffld3_r;
    input [2:0]   n_pic_codtyp_reffld4_r;
    input         c_fldsel1_r;  
    input         c_fldsel2_r;  
    input         c_fldsel3_r;  
    input         c_fldsel4_r;  
    input [4:0]   c_qsc_r; 
    input         c_qst_r; 
    input [11:0]  g_mbc_r;   
    input         g_mbc_en_r;
    input         p_hdtvh_r; 
    input         g_fcyc_en_r;  
    input [17:0]  g_fcyc_r;     
    output [6:0]  c_pcth_mb_r;     
    output [6:0]  c_pctv_mb_r;     
    output [1:0]  c_auto_rpt_md_r; 
    output [21:0] c_fldpl_cycl_r;  
    output        c_pred_forward_r;
    output        c_pred_backward_r;
    output        c_seqhdet_r;      
    output        c_phdet_r;        
    output        c_shdet_r;        
    output        c_mbaidet_s;      
    output        c_fldsel1_fix1_r; 
    output        c_fldsel2_fix1_r; 
    output        c_fldsel3_fix1_r; 
    output        c_fldsel4_fix1_r; 
    output [6:0]  c_qscale_r;  
    output [11:0] c_mbpl_cycl_r; 

    reg [21:0] c_fldpl_cycl_r;     //Field Pulse Cycle Period
    reg [1:0]  c_auto_rpt_md_r;    //Auto Repeat Mode
    reg        c_phdet_r;          //Picture Header Detect
    reg [6:0]  c_pcth_mb_r;        //Pct Size H (MB Scale)
    reg [6:0]  c_pctv_mb_r;        //Pct Size V (MB Scale)
    reg        c_shdet_r;          //Slice Header Detected
    reg        c_pred_forward_r;   //Prediction Forward
    reg        c_pred_backward_r;  //Prediction Backward
    reg        c_fldsel1_fix1_r;   //Mton Vert Fld Sel 1(MPEG Fix)
    reg        c_fldsel2_fix1_r;   //Mton Vert Fld Sel 2(MPEG Fix)
    reg        c_fldsel3_fix1_r;   //Mton Vert Fld Sel 3(MPEG Fix)
    reg        c_fldsel4_fix1_r;   //Mton Vert Fld Sel 4(MPEG Fix)
    reg        c_seqhdet_r;        //Sequence Header Detected
    reg [6:0]  c_qscale_r;         //
    reg        c_nonmc_det_r;      //
    reg [11:0] c_mbpl_cycl_r;      //
    reg        c_mbadet_0_r ;      //
    reg        c_mbadet_1_r ;      //

    wire [7:0] c_pcth_mb_c16;
    wire [8:0] c_pctv_mb_c16;
    wire [7:0] c_pctv_mb_c162;
    wire [7:0] c_pctv_mb_c1622;
    wire [3:0]  c_qsc_ad4;
    wire [3:0]  c_qsc_ad6;
    wire [3:0]  c_qsc_ad7;

//-- Pct Size H (MB Scale) --
    assign c_pcth_mb_c16 = {1'b0,c_hsval_r[10:4]} + |c_hsval_r[3:0];

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_pcth_mb_r <= 7'b111_1111;
          end
        else
          begin
            c_pcth_mb_r <= c_pcth_mb_c16[6:0];
          end
      end

//-- Pct Size V (MB Scale) --
    assign c_pctv_mb_c16 = {1'b0,c_vsval_r[11:4]} + |c_vsval_r[3:0];
    assign c_pctv_mb_c162 = {1'b0,c_pctv_mb_c16[7:1]} + c_pctv_mb_c16[0];
    assign c_pctv_mb_c1622 = {c_pctv_mb_c162[6:0],1'b0};

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_pctv_mb_r <= 7'b111_1111;
          end
        else if (c_pstr_r==2'b11 && c_prgseq_r==1'b1)
          begin
            c_pctv_mb_r <= c_pctv_mb_c16[6:0];
          end
        else if (c_pstr_r==2'b11 && c_prgseq_r==1'b0)
          begin                       
            c_pctv_mb_r <= c_pctv_mb_c1622[6:0];
          end
        else                                    
          begin
            c_pctv_mb_r <= c_pctv_mb_c162[6:0];
          end
      end

//-- Auto Repeat Mode --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_auto_rpt_md_r <= 2'b00;
          end
        else if (c_frate_r==3'b001 || c_frate_r==3'b010)
          begin
            if ((c_hsval_r>{1'b0,g_hs60p_r,4'b0000})
                || (c_vsval_r>{1'b0,g_vs60p_r,4'b0000}))
              begin
                c_auto_rpt_md_r <= 2'b10;
              end
            else
              begin
                c_auto_rpt_md_r <= 2'b01;
              end
          end
        else
          begin
            c_auto_rpt_md_r <= 2'b00; // Modify '04/03/27
          end
      end

//-- Field Pulse Cycle Period --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_fldpl_cycl_r <= 22'h000000;
          end
        else if (g_fcyc_en_r)
          begin
            c_fldpl_cycl_r <= {4'h0,g_fcyc_r};
          end
        else if (c_frate_r==3'b001)
          begin
            if ((c_hsval_r>{1'b0,g_hs60p_r,4'b0000})
                || (c_vsval_r>{1'b0,g_vs60p_r,4'b0000}))
              begin
                c_fldpl_cycl_r <= 22'h1B7E48;
              end
            else
              begin
                c_fldpl_cycl_r <= 22'h0DBF24;
              end
          end
        else if (c_frate_r==3'b010)
          begin
            if ((c_hsval_r>{1'b0,g_hs60p_r,4'b0000})
                || (c_vsval_r>{1'b0,g_vs60p_r,4'b0000}))
              begin
                c_fldpl_cycl_r <= 22'h1B7740;
              end
            else
              begin
                c_fldpl_cycl_r <= 22'h0DBBA0;
              end
          end
        else if (c_frate_r==3'b011)      
          begin
            c_fldpl_cycl_r <= 22'h1B7740;
          end
        else if (c_frate_r==3'b100)      
          begin
            c_fldpl_cycl_r <= 22'h1B7E48;
          end
        else if (c_frate_r==3'b101)      
          begin
            c_fldpl_cycl_r <= 22'h1B7740;
          end
        else if (c_frate_r==3'b110)      
          begin
            c_fldpl_cycl_r <= 22'h01A5E0;
          end
        else if (c_frate_r==3'b111)      
          begin
            c_fldpl_cycl_r <= 22'h0DBF24;
          end
        else   
          begin
            c_fldpl_cycl_r <= 22'h0DBBA0;
          end
      end

//-- Prediction Forward
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_pred_forward_r <= 1'b0;
          end
        else if (c_pic_codtyp_r==3'b010)  
          begin
            c_pred_forward_r <= ~c_mbtyp_0_r;
          end
        else
          begin
            c_pred_forward_r <= c_mbtyp_2_r;
          end
      end

//-- Prediction Backward
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_pred_backward_r <= 1'b0;
          end
        else
          begin
            c_pred_backward_r <= c_mbtyp_1_r;
          end
      end

//-- Sequence Header Detected
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)        
          begin
            c_seqhdet_r <= 1'b0;
          end
        else if (v_seqstrt_r)   
          begin
            c_seqhdet_r <= 1'b1;
          end
        else if (c_mbpl_vld_r_s)
          begin
            c_seqhdet_r <= 1'b0;
          end
        else
          begin
            c_seqhdet_r <= c_seqhdet_r;
          end
      end

//-- Picture Header Detect --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)         
          begin
            c_phdet_r <= 1'b0;
          end
        else if (v_picstrt_r)    
          begin
            c_phdet_r <= 1'b1;
          end
        else if (c_mbpl_vld_r_s) 
          begin
            c_phdet_r <= 1'b0;
          end
        else
          begin
            c_phdet_r <= c_phdet_r;
          end
      end

//-- Slice Header Detected --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)        
          begin
            c_shdet_r <= 1'b0;
          end
        else if (v_slicestart_r)
          begin
            c_shdet_r <= 1'b1;
          end
        else if (c_mbpl_vld_r_s)
          begin
            c_shdet_r <= 1'b0;
          end
        else
          begin
            c_shdet_r <= c_shdet_r;
          end
      end

//-- MB Address Increment Detected --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_mbadet_0_r <= 1'b0;
            c_mbadet_1_r <= 1'b1;
          end
        else
          begin
            c_mbadet_0_r <= v_mbadet_r;
            c_mbadet_1_r <= c_mbadet_0_r;
          end
      end
    assign c_mbaidet_s = c_mbadet_0_r & ~c_mbadet_1_r;

//-- non MC Detected (internal) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_nonmc_det_r <= 1'b0;
          end
        else if ((c_pic_codtyp_r==3'b010) &&
                 (c_mbtyp_2_r==1'b0) &&
                 (c_mbtyp_1_r==1'b0))
          begin
            c_nonmc_det_r <= 1'b1;
          end
        else
          begin
            c_nonmc_det_r <= 1'b0;
          end
      end

//-- Mton Vert Fld Sel 1(MPEG Fix) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_fldsel1_fix1_r <= 1'b0;
          end
        else if (c_nonmc_det_r || c_skpmb_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld1_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    c_fldsel1_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel1_fix1_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    c_fldsel1_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel1_fix1_r <= 1'b0;
                  end
              end
          end
        else
          begin
            c_fldsel1_fix1_r <= c_fldsel1_r;
          end
        end

//-- Mton Vert Fld Sel 2(MPEG Fix) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_fldsel2_fix1_r <= 1'b0;
          end
        else if (c_nonmc_det_r || c_skpmb_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld2_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    c_fldsel2_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel2_fix1_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    c_fldsel2_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel2_fix1_r <= 1'b0;
                  end
              end
          end
        else
          begin
            c_fldsel2_fix1_r <= c_fldsel2_r;
          end
        end

//-- Mton Vert Fld Sel 3(MPEG Fix) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            c_fldsel3_fix1_r <= 1'b0;
          end
        else if (c_nonmc_det_r || c_skpmb_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld3_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    c_fldsel3_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel3_fix1_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    c_fldsel3_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel3_fix1_r <= 1'b0;
                  end
              end
          end
        else
          begin
            c_fldsel3_fix1_r <= c_fldsel3_r;
          end
        end

//-- Mton Vert Fld Sel 4(MPEG Fix) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_fldsel4_fix1_r <= 1'b0;
          end
        else if (c_nonmc_det_r || c_skpmb_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld4_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    c_fldsel4_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel4_fix1_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    c_fldsel4_fix1_r <= 1'b1;
                  end
                else
                  begin
                    c_fldsel4_fix1_r <= 1'b0;
                  end
              end
          end
        else
          begin
            c_fldsel4_fix1_r <= c_fldsel4_r;
          end
        end

//-- Q-scale --
    assign c_qsc_ad4 = {1'b0,c_qsc_r[2:0]} + 4'b0100;
    assign c_qsc_ad6 = {1'b0,c_qsc_r[2:0]} + 4'b0110;
    assign c_qsc_ad7 = {1'b0,c_qsc_r[2:0]} + 4'b0111;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_qscale_r <= 7'b0000000;
          end
        else if (!c_qst_r)    
          begin
            c_qscale_r<= {1'b0,c_qsc_r,1'b0};
          end
        else
          begin
            if (c_qsc_r[4:3]==2'b01)
              begin
                c_qscale_r <= {2'b00,c_qsc_ad4,1'b0};
              end
            else if (c_qsc_r[4:3]==2'b10)
              begin
                c_qscale_r <= {1'b0,c_qsc_ad6,2'b00};
              end
            else if (c_qsc_r[4:3]==2'b11)
              begin
                c_qscale_r <= {c_qsc_ad7,3'b000};
              end
            else     
              begin
                c_qscale_r <= {4'b0000,c_qsc_r[2:0]};
              end
          end
      end

//-- MB Pulse Cycle --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_mbpl_cycl_r <= 12'h000;
          end
        else if (g_mbc_en_r)
          begin
            c_mbpl_cycl_r <= g_mbc_r;
          end
        else if (p_hdtvh_r)
          begin
            c_mbpl_cycl_r <= 12'h1B0;
          end
        else if ((c_frate_r == 3'b110)
                 || (c_frate_r == 3'b111)
                 || (c_frate_r == 3'b000))
          begin
            c_mbpl_cycl_r <= 12'h438;
          end
        else
          begin
            c_mbpl_cycl_r <= 12'h870;
          end
      end

endmodule

