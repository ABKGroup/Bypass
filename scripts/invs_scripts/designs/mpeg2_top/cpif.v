// ----------------------------------------------
// File: cpif.v
// Module: cpif
// Function:
// ----------------------------------------------

module cpif (
    clkdec,       
    rstdec_x,     
    v_paramadr_r,      
    v_paramdata_r,     
    c_mbpl_psft_r_s, 
    c_hsval_r,         
    c_vsval_r,         
    c_frate_r,         
    c_crs_gop_r,       
    c_brklnk_r,        
    c_svp_r,           
    c_qsc_r,           
    c_prgseq_r,        
    c_lwdly_r,         
    c_pic_codtyp_r,    
    c_mpg1_r,          
    c_intradcp_r,      
    c_pstr_r,          
    c_tfst_r,          
    c_qst_r,           
    c_alterscan_r,     
    c_rfstfld_r,       
    c_mbai_r,          
    c_mbtyp_2_r,       
    c_mbtyp_1_r,       
    c_mbtyp_0_r,       
    c_dct_typ_r,       
    c_fldsel1_r,       
    c_dmvh_r,          
    c_dmvv_r,          
    c_fldsel2_r,       
    c_fldsel3_r,       
    c_fldsel4_r,        
    v_mode_mpeg1
  );

    input         clkdec;        
    input         rstdec_x;      
    input [7:0]   v_paramadr_r;    
    input [24:1]  v_paramdata_r;   
    input         c_mbpl_psft_r_s; 
    output        c_lwdly_r;     
    output        c_rfstfld_r;   
    output        c_prgseq_r;    
    output        c_tfst_r;      
    output [17:0] c_mbai_r;      
    output [7:0]  c_svp_r;       
    output [11:0] c_hsval_r;     
    output [11:0] c_vsval_r;     
    output [1:0]  c_pstr_r;      
    output        c_mbtyp_0_r;   
    output        c_dct_typ_r;   
    output [1:0]  c_dmvh_r;      
    output [1:0]  c_dmvv_r;      
    output [4:0]  c_qsc_r;       
    output        c_mpg1_r;      
    output [1:0]  c_intradcp_r;  
    output        c_qst_r;       
    output        c_alterscan_r; 
    output [2:0]  c_pic_codtyp_r;
    output        c_brklnk_r;    
    output        c_crs_gop_r;   
    output [2:0]  c_frate_r;    
    output        c_mbtyp_2_r;  
    output        c_mbtyp_1_r;  
    output        c_fldsel1_r;  
    output        c_fldsel2_r;  
    output        c_fldsel3_r;  
    output        c_fldsel4_r;  
    input         v_mode_mpeg1;

    reg        c_lwdly_r;    
    reg        c_rfstfld_r;  
    reg        c_prgseq_r;   
    reg        c_tfst_r;     
    reg [17:0] c_mbai_r;     
    reg [7:0]  c_svp_r;      
    reg [11:0] c_hsval_r;    
    reg [11:0] c_vsval_r;    
    reg [1:0]  c_pstr_r;     
    reg        c_mbtyp_0_r;   
    reg        c_dct_typ_r;   
    reg [1:0]  c_dmvh_r;      
    reg [1:0]  c_dmvv_r;      
    reg [4:0]  c_qsc_r;       
    reg [4:0]  c_qsc_slc_r;   
    reg        c_mpg1_r;      
    reg [1:0]  c_intradcp_r;  
    reg        c_qst_r;       
    reg        c_alterscan_r; 
    reg [2:0]  c_pic_codtyp_r;
    reg        c_brklnk_r;    
    reg        c_crs_gop_r;   
    reg [2:0]  c_frate_r;     
    reg        c_mbtyp_2_r;   
    reg        c_mbtyp_1_r;   
    reg        c_fldsel1_r;   
    reg        c_fldsel2_r;   
    reg        c_fldsel3_r;   
    reg        c_fldsel4_r;   

    wire [22:0] c_ads_dec;    
   
//--address decode
    function [22:0] ads_dec;
      input [7:0] ads;
      begin
        case (ads)
          8'h00   : ads_dec = 23'b00000000000000000000001;
          8'h02   : ads_dec = 23'b00000000000000000000010;
          8'h09   : ads_dec = 23'b00000000000000000000100;
          8'h0C   : ads_dec = 23'b00000000000000000001000;
          8'h54   : ads_dec = 23'b00000000000000000010000;
          8'h11   : ads_dec = 23'b00000000000000000100000;
          8'h17   : ads_dec = 23'b00000000000000001000000;
          8'h31   : ads_dec = 23'b00000000000000010000000;
          8'h3F   : ads_dec = 23'b00000000000000100000000;
          8'h44   : ads_dec = 23'b00000000000001000000000;
          8'h45   : ads_dec = 23'b00000000000010000000000;
          8'h46   : ads_dec = 23'b00000000000100000000000;
          8'h50   : ads_dec = 23'b00000000001000000000000;
          8'h51   : ads_dec = 23'b00000000010000000000000;
          8'h53   : ads_dec = 23'b00000001000000000000000;
          8'h60   : ads_dec = 23'b00000010000000000000000;
          8'h63   : ads_dec = 23'b00000100000000000000000;
          8'h66   : ads_dec = 23'b00001000000000000000000;
          8'h68   : ads_dec = 23'b00010000000000000000000;
          8'h70   : ads_dec = 23'b00100000000000000000000;
          8'h78   : ads_dec = 23'b01000000000000000000000;
          8'h0D   : ads_dec = 23'b10000000000000000000000;
          default : ads_dec = 23'b00000000000000000000000;
        endcase
      end
    endfunction

    assign c_ads_dec = ads_dec(v_paramadr_r);

//-- ADDRESS 00 (h)        --
//-- horizontal_size_value --
//-- vertical_size_value   --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)          
          begin
            c_hsval_r <= 12'hFE0; 
            c_vsval_r <= 12'hFE0; 
          end
        else if (!c_ads_dec[0])   
          begin
            c_hsval_r <= c_hsval_r;
            c_vsval_r <= c_vsval_r;
          end
        else
          begin
            c_hsval_r <= v_paramdata_r[24:13];
            c_vsval_r <= v_paramdata_r[12:1];
          end
      end

//-- ADDRESS 02 (h)  --
//-- frame_rate_code -- 
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)               
          begin
            c_frate_r <= 3'h0;
          end
        else if (!c_ads_dec[1])        
          begin
            c_frate_r <= c_frate_r;
          end
        else
          begin
            c_frate_r <= v_paramdata_r[19:17];
          end
      end

//-- ADDRESS 09 (h) --
//-- closed_gop     --
//-- broken_link    --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)            
          begin
            c_crs_gop_r <= 1'b0;
            c_brklnk_r  <= 1'b0;
          end
        else if (!c_ads_dec[2])     
          begin
            c_crs_gop_r <= c_crs_gop_r;
            c_brklnk_r  <= c_brklnk_r;
          end
        else
          begin
            c_crs_gop_r <= v_paramdata_r[24];
            c_brklnk_r  <= v_paramdata_r[23];
          end
      end

//-- ADDRESS 0C (h)          --
//-- slice_vertical_position --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)            
          begin
            c_svp_r <= 8'h00;
          end
        else if (!c_ads_dec[3])     
          begin
            c_svp_r <= c_svp_r;
          end
        else
          begin
            c_svp_r <= v_paramdata_r[24:17];
          end
      end

//-- ADDRESS 54 (h)       -- 
//-- quantiser_scale_code --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)         
          begin
            c_qsc_r <= 5'b00000;
          end
        else if (c_ads_dec[4])
          begin
            c_qsc_r <= v_paramdata_r[24:20];
          end
        else if (c_mbpl_psft_r_s)
          begin
            c_qsc_r <= c_qsc_slc_r;
          end
        else
          begin
            c_qsc_r <= c_qsc_r;
          end
      end
//-- ADDRESS 0D (h)       --
//-- ADDRESS 54 (h)       --
//-- quantiser_scale_code --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_qsc_slc_r <= 5'b00000;
          end
        else if (c_ads_dec[4])
          begin
            c_qsc_slc_r <= v_paramdata_r[24:20];
          end
        else if (c_ads_dec[22])
          begin
            c_qsc_slc_r <= v_paramdata_r[24:20];
          end
        else
          begin
            c_qsc_slc_r <= c_qsc_slc_r;
          end
      end

//-- ADDRESS 11 (h)       --
//-- progressive_sequence --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_prgseq_r <= 1'b0;
          end
        else if (c_mpg1_r)
          begin
            c_prgseq_r <= 1'b0;
          end
        else if (!c_ads_dec[5]) 
          begin
            c_prgseq_r <= c_prgseq_r;
          end
        else
          begin
            c_prgseq_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 17 (h) --
//-- low_delay      --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            c_lwdly_r <= 1'b0;
          end
        else if (c_mpg1_r)
          begin
            c_lwdly_r <= 1'b0;
          end
        else if (!c_ads_dec[6])
          begin
            c_lwdly_r <= c_lwdly_r;
          end
        else
          begin
            c_lwdly_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 31 (h)      --
//-- picture_coding_type --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)             
          begin
            c_pic_codtyp_r <= 3'b000;
          end
        else if (!c_ads_dec[7])      
          begin
            c_pic_codtyp_r <= c_pic_codtyp_r;
          end
        else
          begin
            c_pic_codtyp_r <= v_paramdata_r[24:22];
          end
      end

//-- ADDRESS 3F (h) --
//-- MPEG 1         --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_mpg1_r <= 1'b0;
          end
        else if(v_mode_mpeg1)
            c_mpg1_r <= 1'b1; 
        else if (!c_ads_dec[8])
          begin
            c_mpg1_r <= c_mpg1_r;
          end
        else
          begin
            c_mpg1_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 44 (h)     --
//-- intra_dc_precision --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)              
          begin
            c_intradcp_r <= 1'b0;
          end
        else if (!c_ads_dec[9])       
          begin
            c_intradcp_r <= c_intradcp_r;
          end
        else
          begin
            c_intradcp_r <= v_paramdata_r[24:23];
          end
      end

//-- ADDRESS 45 (h)    --
//-- picture_structure --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)        
          begin
            c_pstr_r <= 1'b0;
          end
        else if (c_mpg1_r)
          begin
            c_pstr_r <= 1'b0;
          end
        else if (!c_ads_dec[10])
          begin
            c_pstr_r <= c_pstr_r;
          end
        else
          begin
            c_pstr_r <= v_paramdata_r[24:23];
          end
      end

//-- ADDRESS 46 (h)  [A]  --
//-- top_field_first      --
//-- q_scale_type         --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)        
          begin
            c_tfst_r <= 1'b0;
            c_qst_r  <= 1'b0;
          end
        else if (!c_ads_dec[11]) 
          begin
            if (c_mpg1_r)
              begin
                c_tfst_r <= c_tfst_r;
                c_qst_r  <= 1'b0;
              end
            else
              begin
                c_tfst_r <= c_tfst_r;
                c_qst_r  <= c_qst_r;
              end
          end
        else
          begin
            c_tfst_r <= v_paramdata_r[24];
            c_qst_r  <= v_paramdata_r[21];
          end
      end

//-- ADDRESS 46 (h)  [B]  --
//-- alternate_scan       --
//-- repeat_first_field   --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            c_alterscan_r <= 1'b0;
            c_rfstfld_r   <= 1'b0;
          end
        else if (!c_ads_dec[11]) 
          begin
            c_alterscan_r <= c_alterscan_r;
            c_rfstfld_r   <= c_rfstfld_r;
          end
        else
          begin
            c_alterscan_r <= v_paramdata_r[19];
            c_rfstfld_r   <= v_paramdata_r[18];
          end
      end

//-- ADDRESS 50 (h)               --
//-- macroblock_address_increment --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_mbai_r <= 18'h00000;
          end
        else if (!c_ads_dec[12]) 
          begin
            c_mbai_r <= c_mbai_r;
          end
        else
          begin
            c_mbai_r <= v_paramdata_r[24:7];
          end
      end

//-- ADDRESS 51 (h)  --
//-- macroblock_type --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)           
          begin
            c_mbtyp_0_r <= 1'b0;
            c_mbtyp_1_r <= 1'b0;
            c_mbtyp_2_r <= 1'b0;
          end
        else if (!c_ads_dec[13])   
          begin
            c_mbtyp_0_r <= c_mbtyp_0_r;
            c_mbtyp_1_r <= c_mbtyp_1_r;
            c_mbtyp_2_r <= c_mbtyp_2_r;
          end
        else
          begin
            c_mbtyp_0_r <= v_paramdata_r[22];
            c_mbtyp_1_r <= v_paramdata_r[23];
            c_mbtyp_2_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 53 (h) --
//-- dct_type       --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_dct_typ_r <= 1'b0;
          end
        else if (c_mpg1_r)
          begin
            c_dct_typ_r <= 1'b0;
          end
        else if (!c_ads_dec[15])
          begin
            c_dct_typ_r <= c_dct_typ_r;
          end
        else
          begin
            c_dct_typ_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 60 (h)                     --
//-- motion_vertical_field_select[0][0] --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)              
          begin
            c_fldsel1_r <= 1'b0;
          end
        else if (!c_ads_dec[16])      
          begin
            c_fldsel1_r <= c_fldsel1_r;
          end
        else
          begin
            c_fldsel1_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 63 (h)         --
//-- dmvector[0] Horizontal --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)          
          begin
            c_dmvh_r <= 2'b00;
          end
        else if (!c_ads_dec[17])  
          begin
            c_dmvh_r <= c_dmvh_r;
          end
        else
          begin
            c_dmvh_r <= v_paramdata_r[24:23];
          end
      end

//-- ADDRESS 66 (h)       --
//-- dmvector[1] Vertical --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)       
          begin
            c_dmvv_r <= 2'b00;
          end
        else if (!c_ads_dec[18])
          begin
            c_dmvv_r <= c_dmvv_r;
          end
        else
          begin
            c_dmvv_r <= v_paramdata_r[24:23];
          end
      end

//-- ADDRESS 68 (h)                     --
//-- motion_vertical_field_select[0][1] --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)            
          begin
            c_fldsel2_r <= 1'b0;
          end
        else if (!c_ads_dec[19])    
          begin
            c_fldsel2_r <= c_fldsel2_r;
          end
        else
          begin
            c_fldsel2_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 70 (h)                     --
//-- motion_vertical_field_select[1][0] --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            c_fldsel3_r <= 1'b0;
          end
        else if (!c_ads_dec[20])        
          begin
            c_fldsel3_r <= c_fldsel3_r;
          end
        else
          begin
            c_fldsel3_r <= v_paramdata_r[24];
          end
      end

//-- ADDRESS 78 (h)                     --
//-- motion_vertical_field_select[1][1] --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)         
          begin
            c_fldsel4_r <= 1'b0;
          end
        else if (!c_ads_dec[21]) 
          begin
            c_fldsel4_r <= c_fldsel4_r;
          end
        else
          begin
            c_fldsel4_r <= v_paramdata_r[24];
          end
      end

endmodule


