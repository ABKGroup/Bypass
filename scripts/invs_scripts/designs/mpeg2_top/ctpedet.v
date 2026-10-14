// ----------------------------------------------
// File: ctpedet.v
// Module: ctpedet
// Function:

module ctpedet (
    clkdec, 
    rstdec_x,
    g_pmod_r,             //Picture Period Priority Mode
    g_swrst_r_n,          //Software Reset(N)
    c_mb_fin_r,           //Final MB Position
    c_lwdly_r,            //Low Delay Mode
    g_pcut_r,             //[11:0] TimeOut Cycle Period
    c_fldpl_cnt_r,        //[21:0]Field Pulse Counter
    c_timout_chk_r,       //Time Out Check Flag
    c_pcpl_tend_r_s,      //Picture Processing Time End Pulse
    c_pcpl_r_s,           //Picture Processing Start Pulse
    c_pskp_end_r_s,       //Skip-Picture From CPU
    c_phdet_r,
    c_skippic_r_s,        //Skip Picture Detect
    c_tmg_ferr_hit_r,     //Fatal Error Hit with Timing
    c_picend_ena_r,       //Picture End Permission
    c_pic_notcplt_r       //UnComplete Picture Detected
  );

    input        clkdec;     
    input        rstdec_x;   
    input        g_pmod_r;     
    input        g_swrst_r_n;  
    input        c_mb_fin_r;   
    input        c_lwdly_r;    
    input [11:0] g_pcut_r;     
    input [21:0] c_fldpl_cnt_r;  
    input        c_timout_chk_r; 
    input        c_pcpl_tend_r_s;
    input        c_pcpl_r_s;     
    input        c_pskp_end_r_s; 
    input        c_phdet_r;      

    output       c_skippic_r_s;    
    output       c_tmg_ferr_hit_r; 
    output       c_picend_ena_r;  
    output       c_pic_notcplt_r;  

    reg          c_picproc_det_r;     //Picture Process Detected
    reg          c_tmg_ferr_pre_d1_r; //Fatal Error Hit with Timing
    reg          c_tmg_ferr_hit_r;    //Fatal Error Hit with Timing
    reg          c_skippic_r_s;       //Skip Picture Detect
    reg          c_skippic_dec_r;     //Fatal Error Hit with Timing
    reg          c_skippic_dec_d1_r;  //Fatal Error Hit with Timing
    reg          c_bigpictdet_r;      //Big Picture Detect
    reg          c_picend_ena_r;      //Picture End Permission
    reg          c_pic_notcplt_r;     //UnComplete Picture Detected
    reg          c_phdet_d1_r;

    wire         c_fin_chk_tmg;
    wire         c_tmg_ferr_pre;       //Fatal Error Hit with Timing
    wire         c_skippic_dec_s;      //Fatal Error Hit with Timing
    wire         c_phdet_pedg_s;


//--PHdet Pls Det
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_phdet_d1_r  <= 1'b0;
          end
        else
          begin
            c_phdet_d1_r  <= c_phdet_r;
          end
     end

    assign c_phdet_pedg_s = c_phdet_r & ~c_phdet_d1_r;


//--Picture Finish Timing Det--
    assign c_fin_chk_tmg = ( {10'h000,g_pcut_r} == c_fldpl_cnt_r ) ?
                    c_timout_chk_r : 1'b0;


//--Picture Finish Check --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_bigpictdet_r  <= 1'b0;
            c_picend_ena_r  <= 1'b0;
          end
        else if (c_pcpl_tend_r_s)
          begin
            c_bigpictdet_r  <= 1'b0;
            c_picend_ena_r  <= 1'b0;
          end
        else if (c_fin_chk_tmg)
          begin
            if (c_lwdly_r | g_pmod_r)
              begin
                c_bigpictdet_r  <= 1'b1;
                c_picend_ena_r  <= 1'b0;
              end
            else if (c_phdet_r)
              begin
                c_bigpictdet_r  <= 1'b0;
                c_picend_ena_r  <= 1'b1;
              end
            else
              begin
                c_bigpictdet_r  <= 1'b0;
                c_picend_ena_r  <= 1'b1;
              end
          end
      end

    assign c_tmg_ferr_pre = c_fin_chk_tmg & !(c_lwdly_r | g_pmod_r) & !c_phdet_r & !c_bigpictdet_r;


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_tmg_ferr_pre_d1_r <= 1'b0;
          end
        else
          begin
            c_tmg_ferr_pre_d1_r <= c_tmg_ferr_pre;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_tmg_ferr_hit_r <= 1'b0;
          end
        else
          begin
            c_tmg_ferr_hit_r <= c_tmg_ferr_pre & ~c_tmg_ferr_pre_d1_r;
          end
      end

//--Picture Header Sarch --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_skippic_dec_r <= 1'b0;
          end
        else if (!c_picend_ena_r)
          begin
            c_skippic_dec_r <= 1'b0;
          end
        else
          begin
            if (!c_phdet_r)
              begin
                c_skippic_dec_r <= 1'b1;
              end
            else
              begin
                c_skippic_dec_r <= 1'b0;
              end
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_skippic_dec_d1_r <= 1'b0;
          end
        else
          begin
            c_skippic_dec_d1_r <= c_skippic_dec_r;
          end
      end

    assign c_skippic_dec_s =  c_skippic_dec_r & ~c_skippic_dec_d1_r;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_skippic_r_s <= 1'b0;
          end
        else
          begin
           c_skippic_r_s <= c_skippic_dec_s | c_pskp_end_r_s;
          end
      end

//--Pic Proc Det--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_picproc_det_r  <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_picproc_det_r  <= 1'b0;
          end
        else if (c_picend_ena_r)
          begin
            c_picproc_det_r  <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_picproc_det_r  <= 1'b1;
          end
      end

//--Pic Proc Det--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_pic_notcplt_r  <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_pic_notcplt_r  <= 1'b0;
          end
        else if (!c_picproc_det_r)
          begin
            c_pic_notcplt_r  <= 1'b0;
          end
        else if (c_mb_fin_r)
          begin
            c_pic_notcplt_r  <= 1'b0;
          end
        else if (c_phdet_pedg_s)
          begin
            c_pic_notcplt_r  <= 1'b1;
          end
      end

endmodule

