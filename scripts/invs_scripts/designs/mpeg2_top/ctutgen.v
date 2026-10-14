// ----------------------------------------------
// File: ctutgen.v
// Module: ctutgen
// Function:
// ----------------------------------------------

module ctutgen (
    clkdec,               //Clock
    rstdec_x,             //Asynchronous Reset(N)
    g_vden_r,             //Video Decoder Enable
    g_swrst_r_n,          //Software Reset(N)
    g_pskp_r,             //Picture Skip from CPU 
    c_pstr_r,             //[1:0] Picture Structure
    c_prgseq_r,           //Progressive Sequence
    c_rfstfld_r,          //Repeat First Field
    c_tfst_r,             //Top Field First
    c_lwdly_r,            //Low Delay Mode
    c_fldpl_cycl_r,       //Field Pulse Cycle Period
    c_inipl_r_s,          //Initial Start Pulse
    c_picend_ena_r,       //Picture End Permission
    c_auto_rpt_r,         //Auto Repeat Flag
    c_auto_rpt_05_r,      //Auto Repeat Half Frame
    c_auto_rpt_1_r,       //Auto Repeat 1 Frame
    c_auto_rpt_2_r,       //Auto Repeat 2 Frame
    c_pic_codtyp_r,       //[2:0] Picture Coding Type
    c_frmpl_r_s,          //Frame Pulse
    c_fldpl_r_s,          //Field Pulse
    c_pcpl_r_s,           //Picture Processing Start Pulse
    c_pcpl_tstrt_r_s,     //Picture Processing Time Start Pulse
    c_pcpl_tend_r_s,      //Picture Processing Time End Pulse
    c_fldpl_cnt_r,        //[21:0]Field Pulse Counter
    c_timout_chk_r,       //Time Out Check Flag
    c_idlpl_r_s,          //Video Decoder Idle Pulse 
    c_bfcnt_init_r,       //3page Buffer Initial Pulse
    c_pskp_end_r_s,       //Skip-Picture From CPU     
    v1_sd_pichead_s
  );

    input        clkdec;         
    input        rstdec_x;       
    input        g_vden_r;        
    input        g_swrst_r_n;     
    input        g_pskp_r;        
    input [1:0]  c_pstr_r;        
    input        c_prgseq_r;      
    input        c_rfstfld_r;     
    input        c_tfst_r;        
    input        c_lwdly_r;       
    input [21:0] c_fldpl_cycl_r;  
    input        c_inipl_r_s;     
    input        c_picend_ena_r;  
    input        c_auto_rpt_r;    
    input        c_auto_rpt_05_r; 
    input        c_auto_rpt_1_r;  
    input        c_auto_rpt_2_r;  
    input [2:0]  c_pic_codtyp_r;  

    output        c_frmpl_r_s;     
    output        c_fldpl_r_s;     
    output        c_pcpl_r_s;      
    output        c_pcpl_tstrt_r_s;
    output        c_pcpl_tend_r_s; 
    output [21:0] c_fldpl_cnt_r;   
    output        c_timout_chk_r;  
    output        c_idlpl_r_s;     
    output        c_bfcnt_init_r;  
    output        c_pskp_end_r_s;  
    output        v1_sd_pichead_s;  

    reg           c_frmpl_r_s;          //Frame Pulse
    reg           c_fldpl_r_s;          //Field Pulse
    reg           c_pcpl_r_s;           //Picture Processing Start Pulse
    reg           v1_sd_pichead_s;      //Head Picture Processing Start Pulse
    reg           c_pcpl_tstrt_r_s;     //Picture Processing Time Start Pulse
    reg           c_pcpl_tend_r_s;      //Picture Processing Time End Pulse
    reg    [21:0] c_fldpl_cnt_r;        //Field Pulse Counter
    reg           c_timout_chk_r;       //Time Out Check Flag
    reg           c_idlpl_r_s;          //Video Decoder Idle Pulse
    reg           c_bfcnt_init_r;       //3page Buffer Initial Pulse
    reg           c_pskp_end_r_s;       //Skip-Picture From CPU

    reg           c_fst_init_det_r;     //First Initial Pulse Det
    reg [21:0]    c_fldpl_cnt_pre_r;    //Field Pulse Counter
    reg           c_frmpl_cnt_r;        //Frame Pulse Counter

    reg           c_tfst_b_r;           //Top Field First B picture
    reg           c_tfst_bfr_ip_r;      //Top Field First I/P picture Bfr
    reg           c_tfst_now_ip_r;      //Top Field First I/P picture Now

    reg           c_rfstfld_b_r;        //Rpt First Field B picture
    reg           c_rfstfld_bfr_ip_r;   //Rpt First Field I/P picture Bfr
    reg           c_rfstfld_now_ip_r;   //Rpt First Field I/P picture Now

    reg           c_prgseq_b_r;         //Progressive Seq B picture
    reg           c_prgseq_bfr_ip_r;    //Progressive Seq I/P picture Bfr
    reg           c_prgseq_now_ip_r;    //Progressive Seq I/P picture Now

    reg           c_fst_pcpl_gen_flg_r;   //First Picture Pulse Generate Flag
    reg           c_pictim_flg_r;         //Picture Process Time Flag
    reg           c_chktim_flg_r;         //Picture Time Check Flag
    reg           c_vden_d1_r;            //for Edge Det VDEN
    reg           c_fnlflg_r;             //Final Picture End Flg
    reg           c_initpl_det_r;     
    reg           c_pcpl_tstrt_det_r; 
    reg           c_pcpl_pre_d1_r;    
    reg           c_pskp_end_pre_d1_r;
    reg           c_tstrt_gen_flg_1_r;
    reg           c_tstrt_gen_flg_2_r;
    reg           c_tstrt_gen_flg_3_r;
    reg           c_tstrt_gen_flg_4_r;

    wire          c_fldpl_s;     
    wire          c_frmpl_s;     
    wire          c_fldpl_0_det; 
    wire          c_dec_i_pct;   
    wire          c_dec_p_pct;   
    wire          c_dec_ip_pct;  
    wire          c_tfst_dec;    
    wire          c_rfstfld_dec; 
    wire          c_prgseq_dec;  

    wire          c_pcpl_tend_s;  
    wire          c_pcpl_tstrt_s; 
    wire          c_timout_chk;   
    wire          c_vden_pedg_s;  
    wire          c_fnlpl_pre_s;  
    wire          c_fnlpl_s;      
    wire          c_pcpl_s;       
    wire          c_pctrdy;       
    wire          c_pcpl_pre;
    wire          c_pskp_end_pre;
    wire          c_pskp_end_s;

    reg           c_tstrt_dec0;
    reg           c_tstrt_dec1;
    reg           c_tstrt_dec2;
    reg           c_tstrt_dec4;


//--Init Pls Det--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_fst_init_det_r  <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_fst_init_det_r  <= 1'b0;
          end
        else if (c_inipl_r_s)
          begin
            c_fst_init_det_r  <= 1'b1;
          end
      end

//--Field Cntr --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_fldpl_cnt_pre_r  <= 22'h000001;
          end
        else if (!g_swrst_r_n)
          begin
            c_fldpl_cnt_pre_r  <= 22'h000001;
          end
        else if (c_fst_init_det_r)
          begin
            if (c_fldpl_0_det)
              begin
                c_fldpl_cnt_pre_r  <= (c_fldpl_cycl_r - 1);
              end
            else
              begin
                c_fldpl_cnt_pre_r  <= (c_fldpl_cnt_pre_r - 1);
              end
          end
      end

    assign c_fldpl_0_det = 
           ( c_fldpl_cnt_pre_r == 22'h000000 ) ? 1'b1 : 1'b0;

//--Frame Cntr --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_frmpl_cnt_r  <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_frmpl_cnt_r  <= 1'b0;
          end
        else if (c_fldpl_0_det)
          begin
            c_frmpl_cnt_r  <= ~c_frmpl_cnt_r;
          end
      end

    assign c_frmpl_s = c_fldpl_0_det & g_swrst_r_n & ~c_frmpl_cnt_r;
    assign c_fldpl_s = c_fldpl_0_det & g_swrst_r_n;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_frmpl_r_s   <= 1'b0;
            c_fldpl_r_s   <= 1'b0;
          end
        else
          begin
            c_frmpl_r_s   <= c_frmpl_s;
            c_fldpl_r_s   <= c_fldpl_s;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_fldpl_cnt_r <= 22'h000001;
          end
        else if (!g_swrst_r_n)
          begin
            c_fldpl_cnt_r <= 22'h000001;
          end
        else
          begin
            c_fldpl_cnt_r <= c_fldpl_cnt_pre_r;
          end
      end


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_tfst_b_r     <= 1'b1;
            c_rfstfld_b_r  <= 1'b0;
            c_prgseq_b_r   <= 1'b0;
          end
        else if (c_pcpl_s)
          begin
            c_tfst_b_r     <= c_tfst_r;
            c_rfstfld_b_r  <= c_rfstfld_r;
            c_prgseq_b_r   <= c_prgseq_r;
          end
      end

    assign c_dec_i_pct  = ( c_pic_codtyp_r == 3'b001 ) ? 1'b1 : 1'b0;
    assign c_dec_p_pct  = ( c_pic_codtyp_r == 3'b010 ) ? 1'b1 : 1'b0;
    assign c_dec_ip_pct = (c_dec_i_pct | c_dec_p_pct) & ~c_lwdly_r;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_tfst_now_ip_r     <= 1'b0;
            c_tfst_bfr_ip_r     <= 1'b0;
            c_rfstfld_now_ip_r  <= 1'b0;
            c_rfstfld_bfr_ip_r  <= 1'b0;
            c_prgseq_now_ip_r   <= 1'b0;
            c_prgseq_bfr_ip_r   <= 1'b0;
          end
        else if (c_pcpl_s)
          begin
            if (c_dec_ip_pct)
              begin
                c_tfst_now_ip_r     <= c_tfst_r;
                c_tfst_bfr_ip_r     <= c_tfst_now_ip_r;
                c_rfstfld_now_ip_r  <= c_rfstfld_r;
                c_rfstfld_bfr_ip_r  <= c_rfstfld_now_ip_r;
                c_prgseq_now_ip_r   <= c_prgseq_r;
                c_prgseq_bfr_ip_r   <= c_prgseq_now_ip_r;
              end
          end
      end

      assign c_tfst_dec = (c_dec_ip_pct == 1'b0)    ? 
             c_tfst_b_r : c_tfst_bfr_ip_r;
      assign c_rfstfld_dec = (c_dec_ip_pct == 1'b0) ? 
             c_rfstfld_b_r : c_rfstfld_bfr_ip_r;
      assign c_prgseq_dec = (c_dec_ip_pct == 1'b0)  ? 
             c_prgseq_b_r : c_prgseq_bfr_ip_r;


//--First PicturePulse Generate Flag
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_fst_pcpl_gen_flg_r  <= 1'b1;
          end
        else if (!g_swrst_r_n | !g_vden_r)
          begin
            c_fst_pcpl_gen_flg_r  <= 1'b1;
          end
        else if (c_fldpl_s)
          begin
            c_fst_pcpl_gen_flg_r  <= 1'b0;
          end
      end

//--PicturePulse Generate Flag 0 - 4
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)         
          begin
            c_tstrt_gen_flg_1_r  <= 1'b0;
          end
        else if (!g_vden_r)
          begin
            c_tstrt_gen_flg_1_r  <= 1'b0;
          end
        else if (c_pcpl_tstrt_s)
          begin
            c_tstrt_gen_flg_1_r  <= 1'b0;
          end
        else if (c_fldpl_s)
          begin
            if (c_picend_ena_r)
              begin
                c_tstrt_gen_flg_1_r  <= 1'b1;
              end
            else
              begin
                c_tstrt_gen_flg_1_r  <= 1'b0;
              end
          end
        else
          begin
            c_tstrt_gen_flg_1_r  <= c_tstrt_gen_flg_1_r;
          end
      end


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_tstrt_gen_flg_2_r  <= 1'b0;
          end
        else if (!g_vden_r)
          begin
            c_tstrt_gen_flg_2_r  <= 1'b0;
          end
        else if (c_pcpl_tstrt_s)
          begin
            c_tstrt_gen_flg_2_r  <= 1'b0;
          end
        else if (c_fldpl_s)
          begin
            if (c_tstrt_gen_flg_1_r)
              begin
                c_tstrt_gen_flg_2_r  <= 1'b1;
              end
            else
              begin
                c_tstrt_gen_flg_2_r  <= 1'b0;
              end
          end
        else
          begin
            c_tstrt_gen_flg_2_r  <= c_tstrt_gen_flg_2_r;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_tstrt_gen_flg_3_r  <= 1'b0;
          end
        else if (!g_vden_r)
          begin
            c_tstrt_gen_flg_3_r  <= 1'b0;
          end
        else if (c_pcpl_tstrt_s)
          begin
            c_tstrt_gen_flg_3_r  <= 1'b0;
          end
        else if (c_fldpl_s)
          begin
            if (c_tstrt_gen_flg_2_r)
              begin
                c_tstrt_gen_flg_3_r  <= 1'b1;
              end
            else
              begin
                c_tstrt_gen_flg_3_r  <= 1'b0;
              end
          end
        else
          begin
            c_tstrt_gen_flg_3_r  <= c_tstrt_gen_flg_3_r;
          end
      end


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_tstrt_gen_flg_4_r  <= 1'b0;
          end
        else if (!g_vden_r)
          begin
            c_tstrt_gen_flg_4_r  <= 1'b0;
          end
        else if (c_pcpl_tstrt_s)
          begin
            c_tstrt_gen_flg_4_r  <= 1'b0;
          end
        else if (c_fldpl_s)
          begin
            if (c_tstrt_gen_flg_3_r)
              begin
                c_tstrt_gen_flg_4_r  <= 1'b1;
              end
            else
              begin
                c_tstrt_gen_flg_4_r  <= 1'b0;
              end
          end
        else
          begin
            c_tstrt_gen_flg_4_r  <= c_tstrt_gen_flg_4_r;
          end
      end

    always @(c_auto_rpt_r or c_auto_rpt_05_r or c_auto_rpt_1_r or 
            c_auto_rpt_2_r or c_rfstfld_dec or c_prgseq_dec or 
            c_tfst_dec )
      begin
        if (c_auto_rpt_r)
          begin
            if (c_auto_rpt_05_r)
              begin
                c_tstrt_dec0  = 1'b0;
                c_tstrt_dec1  = 1'b1;
                c_tstrt_dec2  = 1'b0;
                c_tstrt_dec4  = 1'b0;
              end
            else if (c_auto_rpt_1_r)
              begin
                c_tstrt_dec0  = 1'b0;
                c_tstrt_dec1  = 1'b0;
                c_tstrt_dec2  = 1'b1;
                c_tstrt_dec4  = 1'b0;
              end
            else if (c_auto_rpt_2_r)
              begin
                c_tstrt_dec0  = 1'b0;
                c_tstrt_dec1  = 1'b0;
                c_tstrt_dec2  = 1'b0;
                c_tstrt_dec4  = 1'b1;
              end
            else
              begin
                c_tstrt_dec0  = 1'b1;
                c_tstrt_dec1  = 1'b0;
                c_tstrt_dec2  = 1'b0;
                c_tstrt_dec4  = 1'b0;
              end
          end
        else
          begin
            if (!c_rfstfld_dec)
              begin
                if (c_auto_rpt_05_r)
                  begin
                    c_tstrt_dec0  = 1'b0;
                    c_tstrt_dec1  = 1'b1;
                    c_tstrt_dec2  = 1'b0;
                    c_tstrt_dec4  = 1'b0;
                  end
                else if (c_auto_rpt_1_r)
                  begin
                    c_tstrt_dec0  = 1'b0;
                    c_tstrt_dec1  = 1'b0;
                    c_tstrt_dec2  = 1'b1;
                    c_tstrt_dec4  = 1'b0;
                  end
                else if (c_auto_rpt_2_r)
                  begin
                    c_tstrt_dec0  = 1'b0;
                    c_tstrt_dec1  = 1'b0;
                    c_tstrt_dec2  = 1'b0;
                    c_tstrt_dec4  = 1'b1;
                  end
                else
                  begin
                    c_tstrt_dec0  = 1'b1;
                    c_tstrt_dec1  = 1'b0;
                    c_tstrt_dec2  = 1'b0;
                    c_tstrt_dec4  = 1'b0;
                  end
              end
            else if (!c_prgseq_dec)
              begin
                c_tstrt_dec0  = 1'b0;
                c_tstrt_dec1  = 1'b1;
                c_tstrt_dec2  = 1'b0;
                c_tstrt_dec4  = 1'b0;
              end
            else if (!c_tfst_dec)
              begin
                c_tstrt_dec0  = 1'b0;
                c_tstrt_dec1  = 1'b0;
                c_tstrt_dec2  = 1'b1;
                c_tstrt_dec4  = 1'b0;
              end
            else
              begin
                c_tstrt_dec0  = 1'b0;
                c_tstrt_dec1  = 1'b0;
                c_tstrt_dec2  = 1'b0;
                c_tstrt_dec4  = 1'b1;
              end
          end
      end

    assign c_pcpl_tstrt_s =  g_vden_r & c_fldpl_s
                             &  (  c_fst_pcpl_gen_flg_r
                                |  (c_tstrt_dec0 & c_picend_ena_r)
                                |  (c_tstrt_dec1 & c_tstrt_gen_flg_1_r)
                                |  (c_tstrt_dec2 & c_tstrt_gen_flg_2_r)
                                |  (c_tstrt_dec4 & c_tstrt_gen_flg_4_r) );
    assign c_pcpl_tend_s  =  c_picend_ena_r & c_fldpl_s;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_pcpl_tend_r_s   <= 1'b0;
            c_pcpl_tstrt_r_s  <= 1'b0;
          end
        else
          begin
            c_pcpl_tend_r_s   <= c_pcpl_tend_s;
            c_pcpl_tstrt_r_s  <= c_pcpl_tstrt_s;
          end
      end

//--Picture Processing Time Flag --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_pictim_flg_r  <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_pictim_flg_r  <= 1'b0;
          end
        else if (c_pcpl_tstrt_s)
          begin
            c_pictim_flg_r  <= 1'b1;
          end
        else if (c_pcpl_tend_s)
          begin
            c_pictim_flg_r  <= 1'b0;
          end
      end

//--TimeOut Check Tmg Gen --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_chktim_flg_r  <= 1'b0;
          end
        else if (c_pcpl_tend_s)
          begin
            c_chktim_flg_r  <= 1'b0;
          end
        else if (c_fldpl_s)
          begin
            if (c_pictim_flg_r)
              begin
                c_chktim_flg_r  <= ~c_chktim_flg_r;
              end
          end
      end

    assign c_timout_chk = 
                ~(c_pstr_r[1] & c_pstr_r[0]) & c_pictim_flg_r;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_timout_chk_r  <= 1'b0;
          end
        else
          begin
            c_timout_chk_r  <= c_chktim_flg_r | c_timout_chk;
          end
      end

//--Idle Start Tmg Gen --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_vden_d1_r <= 1'b0;
          end
        else
          begin
            c_vden_d1_r <= g_vden_r;
          end
      end

    assign c_vden_pedg_s =  g_vden_r & ~c_vden_d1_r;
    assign c_fnlpl_pre_s = 
                ( c_pictim_flg_r == 1'b1 ) ? c_pcpl_tend_s : c_fldpl_s;
    assign c_fnlpl_s = c_fnlpl_pre_s & ~g_vden_r;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_fnlflg_r <= 1'b0;
          end
        else if (c_fnlpl_s)
          begin
            c_fnlflg_r <= 1'b1;
          end
        else if (c_vden_pedg_s)
          begin
            c_fnlflg_r <= 1'b0;
          end
      end

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_idlpl_r_s  <= 1'b0;
          end
        else
          begin
            c_idlpl_r_s  <= c_fnlpl_s & ~c_fnlflg_r;
          end
      end


//--Init Pls Det Flg --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_initpl_det_r <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_initpl_det_r <= 1'b0;
          end
        else if (!c_inipl_r_s)
          begin
            if (!(c_pcpl_s |c_pskp_end_r_s))
              begin
                c_initpl_det_r <= c_initpl_det_r;
              end
            else
              begin
                c_initpl_det_r <= 1'b0;
              end
          end
        else
          begin
            c_initpl_det_r <= 1'b1;
          end
      end

//--Pic Tim Start Pls Det Flg --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_pcpl_tstrt_det_r <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_pcpl_tstrt_det_r <= 1'b0;
          end
        else if (!g_vden_r)
          begin
            c_pcpl_tstrt_det_r <= 1'b0;
          end
        else if (!c_pcpl_tstrt_r_s)
          begin
            if (!c_pcpl_s)
              begin
                c_pcpl_tstrt_det_r <= c_pcpl_tstrt_det_r;
              end
            else
              begin
                c_pcpl_tstrt_det_r <= 1'b0;
              end
          end
        else
          begin
            c_pcpl_tstrt_det_r <= 1'b1;
          end
      end

//--Pic Process Start Pls Generate --
    assign c_pctrdy = c_initpl_det_r & c_pcpl_tstrt_det_r ;
    assign c_pcpl_pre          = c_pctrdy & ~g_pskp_r;
    assign c_pskp_end_pre      = c_pctrdy &  g_pskp_r;


    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_pcpl_pre_d1_r        <= 1'b0;
            c_pskp_end_pre_d1_r    <= 1'b0;
          end
        else
          begin
            c_pcpl_pre_d1_r        <= c_pcpl_pre;
            c_pskp_end_pre_d1_r    <= c_pskp_end_pre;
          end
      end

    assign c_pcpl_s      = c_pcpl_pre     & ~c_pcpl_pre_d1_r;
    assign c_pskp_end_s  = c_pskp_end_pre & ~c_pskp_end_pre_d1_r;

    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_pcpl_r_s         <= 1'b0;
            c_bfcnt_init_r     <= 1'b0;
            v1_sd_pichead_s      <= 1'b0;
            c_pskp_end_r_s     <= 1'b0;
          end
        else
          begin
            c_pcpl_r_s        <= c_pcpl_s;
            c_bfcnt_init_r    <= c_pcpl_s;
            v1_sd_pichead_s     <= c_pcpl_s;
            c_pskp_end_r_s    <= c_pskp_end_s;
          end
      end

endmodule


