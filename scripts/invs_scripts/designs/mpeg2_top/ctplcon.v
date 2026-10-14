// ----------------------------------------------
// File: ctplcon.v
// Module: ctplcon
// Function:
// ----------------------------------------------

module ctplcon (
    clkdec,               //Clock
    rstdec_x,             //Asynchronous Reset(N)
    g_swrst_r_n,          //Software Reset(N)
    c_phdet_r,            //Picture Header Detected
    c_mbaidet_s,          //MBAI Detected
    c_mb_fin_r,           //Final MB Position
    c_ccl_r,              //Conceal Command
    c_skpmb_r,            //Skip MB Command
    c_mbpl_base_r_s,      //MB Pulse(Base Pulse)
    c_pcpl_r_s,           //
    c_picend_ena_r,       //
    c_mbpl_vld_r_s,       //MB Pulse(Variable Length-code Decord)
    c_mbpl_iq_r_s,        //MB Pulse(Inverce Quantization)
    c_mbpl_idct_r_s,      //MB Pulse(Inverce DCT)
    c_mbpl_idct_out_r_s,  //MB Pulse(Inverce DCT Data Output)
    c_mbpl_mcalc_r_s,     //MB Pulse(Motion Vector Calculation)
    c_mbpl_buc_r_s,       //MB Pulse(Bus Operation with Up Conversion)
    c_mbpl_uc_r_s,        //MB Pulse(Up Conversion phase
    c_mbpl_mc_r_s,        //MB Pulse(Motion Compensation)
    c_mbpl_dc_r_s,        //MB Pulse(Down Conversion)
    c_mbpl_psft_r_s,      //MB Pulse(Parameter Shift)
    c_mbpl_pos_r_s,       //MB Pulse(MB Position Renobation)
    c_mbpl_skpmb_r_s      //MB Pulse(Skip MB Det)
  );

    input        clkdec;   
    input        rstdec_x; 
    input        g_swrst_r_n;
    input        c_phdet_r;  
    input        c_mbaidet_s;
    input        c_mb_fin_r; 
    input        c_ccl_r;    
    input        c_skpmb_r;  
    input        c_mbpl_base_r_s; 
    input        c_pcpl_r_s;      
    input        c_picend_ena_r;  
    output       c_mbpl_vld_r_s;     
    output       c_mbpl_iq_r_s;      
    output       c_mbpl_idct_r_s;    
    output       c_mbpl_idct_out_r_s;
    output       c_mbpl_mcalc_r_s;   
    output       c_mbpl_buc_r_s;     
    output       c_mbpl_uc_r_s;      
    output       c_mbpl_mc_r_s;      
    output       c_mbpl_dc_r_s;      
    output       c_mbpl_psft_r_s;    
    output       c_mbpl_pos_r_s;     
    output       c_mbpl_skpmb_r_s;   

    reg          c_mbpl_vld_r_s;      //MB Pulse(Variable Length-code Decord)
    reg          c_mbpl_iq_r_s;       //MB Pulse(Inverce Quantization)
    reg          c_mbpl_idct_r_s;     //MB Pulse(Inverce DCT)
    reg          c_mbpl_idct_out_r_s; //MB Pulse(Inverce DCT Data Output)
    reg          c_mbpl_mcalc_r_s;    //MB Pulse(Motion Vector Calculation)
    reg          c_mbpl_buc_r_s;      //...(Bus Operation with Up Conversion)
    reg          c_mbpl_uc_r_s;       //MB Pulse(Up Conversion phase)
    reg          c_mbpl_mc_r_s;       //MB Pulse(Motion Compensation)
    reg          c_mbpl_dc_r_s;       //MB Pulse(Down Conversion)
    reg          c_mbpl_psft_r_s;     //MB Pulse(Parameter Shift)
    reg          c_mbpl_pos_r_s;      //MB Pulse(MB Position Renobation)
    reg          c_mbpl_skpmb_r_s;    //MB Pulse(Skip MB Det)
    reg          c_frm_mbpl_ena_r;    // MB Pulse Enable
    reg          c_frm_mbpl_r;        //Frame for Generate MB Pulse
    reg          c_frm_stg1_r;        //Frame for Pipeline Stage 1
    reg          c_frm_stg1_skpmb_r;  //Frame for Pipeline Stage 1 with skpmb
    reg          c_frm_stg2_r;        //Frame for Pipeline Stage 2
    reg          c_frm_stg3_r;        //Frame for Pipeline Stage 3
    reg          c_frm_stg4_r;        //Frame for Pipeline Stage 4
    reg          c_frm_stg5_r;        //Frame for Pipeline Stage 5

    reg          c_skpmb_d1_r;        //For Edge Detect (SkipMB)
    reg          c_frm_stg5_d1_r;     //For Edge Detect (Stage5)

    reg          c_vld_delay_r;
    reg          c_iq_delay_r;      //DLY FLG(Inverce Quantization)
    reg          c_idct_delay_r;    //DLY FLG(Inverce DCT)
    reg          c_idct_out_delay_r;//DLY FLG(Inverce DCT Data Output)
    reg          c_mcalc_delay_r;   //DLY FLG(Motion Vector Calculation)
    reg          c_buc_delay_r;     //...(Bus Operation with Up Conversion)
    reg          c_uc_delay_r;      //DLY FLG(Up Conversion phase)
    reg          c_mc_delay_r;      //DLY FLG(Motion Compensation)
    reg          c_dc_delay_r;      //DLY FLG(Down Conversion)

    reg [11:0]   c_vld_delay_cnt;
    reg [11:0]   c_iq_delay_cnt;      //DLY CNTR(Inverce Quantization)
    reg [11:0]   c_idct_delay_cnt;    //DLY CNTR(Inverce DCT)
    reg [11:0]   c_idct_out_delay_cnt;//DLY CNTR(Inverce DCT Data Output)
    reg [11:0]   c_mcalc_delay_cnt;   //DLY CNTR(Motion Vector Calculation)
    reg [11:0]   c_buc_delay_cnt;     //...(Bus Operation with Up Conversion)
    reg [11:0]   c_uc_delay_cnt;      //DLY CNTR(Up Conversion phase)
    reg [11:0]   c_mc_delay_cnt;      //DLY CNTR(Motion Compensation)
    reg [11:0]   c_dc_delay_cnt;      //DLY CNTR(Down Conversion)

    wire         c_mbpl_ppl_s;          //MB Pulse(Pipeline)
    wire         c_frm_stg1_vld;        //Frame for Pipeline Stage 1 with vld
    wire         c_mbpl_stg1_s;         //MB Pulse Stage1
    wire         c_mbpl_stg1_vld_s;     //MB Pulse Stage1_vld
    wire         c_mbpl_stg1_skpmb_s;   //MB Pulse Stage1_skpmb
    wire         c_mbpl_stg2_s;         //MB Pulse Stage2
    wire         c_mbpl_stg3_s;         //MB Pulse Stage3
    wire         c_mbpl_stg4_s;         //MB Pulse Stage4
    wire         c_mbpl_stg5_s;         //MB Pulse Stage5

    wire         c_skpmb_pedg_s;        //SkipMB PosEdge
    wire         c_frm_stg5_nedg_s;     //FrmStg5 NegEdge

//--parameter--

    parameter   P_VLD_DELAY      = 12'd1;
    parameter   P_IQ_DELAY       = 12'd1; 
    parameter   P_IDCT_DELAY     = 12'd1; 
    parameter   P_IDCT_OUT_DELAY = 12'd145;
    parameter   P_MCALC_DELAY    = 12'd1;
    parameter   P_BUC_DELAY      = 12'd5;
    parameter   P_UC_DELAY       = 12'd145;
    parameter   P_MC_DELAY       = 12'd145;
    parameter   P_DC_DELAY       = 12'd145;


//--edge detetc--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_skpmb_d1_r    <= 1'b0;
            c_frm_stg5_d1_r <= 1'b0;
          end
        else
          begin
            c_skpmb_d1_r    <= c_skpmb_r;
            c_frm_stg5_d1_r <= c_frm_stg5_r;
          end
      end
    
    assign c_skpmb_pedg_s    = ~c_skpmb_d1_r    &  c_skpmb_r    ;
    assign c_frm_stg5_nedg_s =  c_frm_stg5_d1_r &  ~c_frm_stg5_r;

//--MB pulse enable detect--
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_frm_mbpl_ena_r    <= 1'b0;
          end
        else if (c_mbaidet_s)
          begin
            c_frm_mbpl_ena_r    <= 1'b1;
          end
        else if (c_mbpl_vld_r_s)
          begin
            c_frm_mbpl_ena_r    <= 1'b0;
          end
      end

//--Macroblock generage frame
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_frm_mbpl_r <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_frm_mbpl_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_frm_mbpl_r <= 1'b1;
          end
        else if (c_frm_stg5_nedg_s | c_picend_ena_r )
          begin
            c_frm_mbpl_r <= 1'b0;
          end
      end

    assign c_mbpl_ppl_s = 
      c_frm_mbpl_r & ( c_mb_fin_r | c_frm_mbpl_ena_r | c_ccl_r) & c_mbpl_base_r_s;

//--stage 1 frame
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_frm_stg1_r <= 1'b0;
          end
        else if (!g_swrst_r_n)
          begin
            c_frm_stg1_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_frm_stg1_r <= 1'b1;
          end
        else if ((c_mb_fin_r & c_phdet_r) | c_picend_ena_r )
          begin
            c_frm_stg1_r <= 1'b0;
          end
      end
    
//--Stage 2 - 5 frame
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_frm_stg2_r <= 1'b0;
            c_frm_stg3_r <= 1'b0;
            c_frm_stg4_r <= 1'b0;
            c_frm_stg5_r <= 1'b0;
          end
        else if (c_pcpl_r_s | c_picend_ena_r | !g_swrst_r_n)
          begin
            c_frm_stg2_r <= 1'b0;
            c_frm_stg3_r <= 1'b0;
            c_frm_stg4_r <= 1'b0;
            c_frm_stg5_r <= 1'b0;
          end
        else if (c_mbpl_base_r_s)
          begin
            c_frm_stg2_r <= c_frm_stg1_r;
            c_frm_stg3_r <= c_frm_stg2_r;
            c_frm_stg4_r <= c_frm_stg3_r;
            c_frm_stg5_r <= c_frm_stg4_r;
          end
      end
    
//--Stage 1 ( VLD )frame
    assign c_frm_stg1_vld = c_frm_stg1_r & ~c_ccl_r & ~c_skpmb_r;

//--Stage 1 ( Skip MB)frame
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_frm_stg1_skpmb_r <= 1'b0;
          end
        else if (c_skpmb_pedg_s)
          begin
            c_frm_stg1_skpmb_r <= 1'b1;
          end
        else if (c_mbpl_ppl_s)
          begin
            c_frm_stg1_skpmb_r <= 1'b0;
          end
        else
          begin
            c_frm_stg1_skpmb_r <= c_frm_stg1_skpmb_r;
          end
      end
    

    assign c_mbpl_stg1_s       = c_frm_stg1_r       & c_mbpl_ppl_s;
    assign c_mbpl_stg1_vld_s   = c_frm_stg1_vld     & c_mbpl_ppl_s;
    assign c_mbpl_stg1_skpmb_s = c_frm_stg1_skpmb_r & c_mbpl_ppl_s;
    assign c_mbpl_stg2_s       = c_frm_stg2_r       & c_mbpl_ppl_s;
    assign c_mbpl_stg3_s       = c_frm_stg3_r       & c_mbpl_ppl_s;
    assign c_mbpl_stg4_s       = c_frm_stg4_r       & c_mbpl_ppl_s;
    assign c_mbpl_stg5_s       = c_frm_stg5_r       & c_mbpl_ppl_s;


//--DLY FLG VLD Phase
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_vld_delay_r    <= 1'b0;
          end
        else if (c_mbpl_stg1_vld_s)
          begin
            c_vld_delay_r    <= 1'b1;
          end
        else if (c_vld_delay_cnt == P_VLD_DELAY)
          begin
            c_vld_delay_r    <= 1'b0;
          end
      end


//--DLY FLG IQ Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_iq_delay_r    <= 1'b0;
          end
        else if (c_mbpl_stg2_s)
          begin
            c_iq_delay_r    <= 1'b1;
          end
        else if (c_iq_delay_cnt == P_IQ_DELAY)
          begin
            c_iq_delay_r    <= 1'b0;
          end
      end

//--DLY FLG IDCT Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_idct_delay_r    <= 1'b0;
          end
        else if (c_mbpl_stg2_s)
          begin
            c_idct_delay_r    <= 1'b1;
          end
        else if (c_idct_delay_cnt == P_IDCT_DELAY)
          begin
            c_idct_delay_r    <= 1'b0;
          end
      end


//--DLY FLG IDCT Output Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_idct_out_delay_r <= 1'b0;
          end
        else if (c_mbpl_stg2_s)
          begin
            c_idct_out_delay_r <= 1'b1;
          end
        else if (c_idct_out_delay_cnt == P_IDCT_OUT_DELAY)
          begin
            c_idct_out_delay_r <= 1'b0;
          end
      end

//--DLY FLG MCalc Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mcalc_delay_r <= 1'b0;
          end
        else if (c_mbpl_stg2_s)
          begin
            c_mcalc_delay_r <= 1'b1;
          end
        else if (c_mcalc_delay_cnt == P_MCALC_DELAY)
          begin
            c_mcalc_delay_r <= 1'b0;
          end
      end


//--DLY FLG BUC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_buc_delay_r <= 1'b0;
          end
        else if (c_mbpl_stg2_s)
          begin
            c_buc_delay_r <= 1'b1;
          end
        else if (c_buc_delay_cnt == P_BUC_DELAY)
          begin
            c_buc_delay_r <= 1'b0;
          end
      end


//--DLY FLG UC Phase
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_uc_delay_r <= 1'b0;
          end
        else if (c_mbpl_stg3_s)
          begin
            c_uc_delay_r <= 1'b1;
          end
        else if (c_uc_delay_cnt == P_UC_DELAY)
          begin
            c_uc_delay_r <= 1'b0;
          end
      end

//--DLY FLG MC Phase
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mc_delay_r <= 1'b0;
          end
        else if (c_mbpl_stg4_s)
          begin
            c_mc_delay_r <= 1'b1;
          end
        else if (c_mc_delay_cnt == P_MC_DELAY)
          begin
            c_mc_delay_r <= 1'b0;
          end
      end

//--DLY FLG DC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_dc_delay_r <= 1'b0;
          end
        else if (c_mbpl_stg5_s)
          begin
            c_dc_delay_r <= 1'b1;
          end
        else if (c_dc_delay_cnt == P_DC_DELAY)
          begin
            c_dc_delay_r <= 1'b0;
          end
      end

//--DLY CNT VLD Phase
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_vld_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg1_vld_s || c_vld_delay_r)
          begin
            c_vld_delay_cnt    <= c_vld_delay_cnt + 1;
          end
        else
          begin
            c_vld_delay_cnt    <= 12'h000;
          end
      end

//--DLY CNT IQ Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_iq_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg2_s || c_iq_delay_r)
          begin
            c_iq_delay_cnt    <= c_iq_delay_cnt + 1;
          end
        else
          begin
            c_iq_delay_cnt    <= 12'h000;
          end
      end

//--DLY CNT IDCT Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_idct_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg2_s || c_idct_delay_r)
          begin
            c_idct_delay_cnt    <= c_idct_delay_cnt + 1;
          end
        else
          begin
            c_idct_delay_cnt    <= 12'h000;
          end
      end


//--DLY CNT IDCT Output Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_idct_out_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg2_s || c_idct_out_delay_r)
          begin
            c_idct_out_delay_cnt    <= c_idct_out_delay_cnt + 1;
          end
        else
          begin
            c_idct_out_delay_cnt    <= 12'h000;
          end
      end

//--DLY CNT MCalc Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_mcalc_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg2_s || c_mcalc_delay_r)
          begin
            c_mcalc_delay_cnt    <= c_mcalc_delay_cnt + 1;
          end
        else
          begin
            c_mcalc_delay_cnt    <= 12'h000;
          end
      end


//--DLY CNT BUC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_buc_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg2_s || c_buc_delay_r)
          begin
            c_buc_delay_cnt    <= c_buc_delay_cnt + 1;
          end
        else
          begin
            c_buc_delay_cnt    <= 12'h000;
          end
      end


//--DLY CNT UC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_uc_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg3_s || c_uc_delay_r)
          begin
            c_uc_delay_cnt    <= c_uc_delay_cnt + 1;
          end
        else
          begin
            c_uc_delay_cnt    <= 12'h000;
          end
      end


//--DLY CNT MC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_mc_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg4_s || c_mc_delay_r)
          begin
            c_mc_delay_cnt    <= c_mc_delay_cnt + 1;
          end
        else
          begin
            c_mc_delay_cnt    <= 12'h000;
          end
      end

//--DLY CNT DC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_dc_delay_cnt    <= 12'h000;
          end
        else if (c_mbpl_stg5_s || c_dc_delay_r)
          begin
            c_dc_delay_cnt    <= c_dc_delay_cnt + 1;
          end
        else
          begin
            c_dc_delay_cnt    <= 12'h000;
          end
      end

//--DLY FLG VLD Phase
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_mbpl_vld_r_s    <= 1'b0;
          end
        else if (c_vld_delay_cnt == P_VLD_DELAY)
          begin
            c_mbpl_vld_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_vld_r_s    <= 1'b0;
          end
      end

//--DLY FLG IQ Phase
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_mbpl_iq_r_s    <= 1'b0;
          end
        else if (c_iq_delay_cnt == P_IQ_DELAY)
          begin
            c_mbpl_iq_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_iq_r_s    <= 1'b0;
          end
      end


//--DLY FLG IDCT Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_mbpl_idct_r_s    <= 1'b0;
          end
        else if (c_idct_delay_cnt == P_IDCT_DELAY)
          begin
            c_mbpl_idct_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_idct_r_s    <= 1'b0;
          end
      end


//--DLY FLG IDCT Output Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_mbpl_idct_out_r_s    <= 1'b0;
          end
        else if (c_idct_out_delay_cnt == P_IDCT_OUT_DELAY)
          begin
            c_mbpl_idct_out_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_idct_out_r_s    <= 1'b0;
          end
      end


//--DLY FLG MCalc Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_mbpl_mcalc_r_s    <= 1'b0;
          end
        else if (c_mcalc_delay_cnt == P_MCALC_DELAY)
          begin
            c_mbpl_mcalc_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_mcalc_r_s    <= 1'b0;
          end
      end


//--DLY FLG BUC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_mbpl_buc_r_s    <= 1'b0;
          end
        else if (c_buc_delay_cnt == P_BUC_DELAY)
          begin
            c_mbpl_buc_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_buc_r_s    <= 1'b0;
          end
      end


//--DLY FLG UC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mbpl_uc_r_s    <= 1'b0;
          end
        else if (c_uc_delay_cnt == P_UC_DELAY)
          begin
            c_mbpl_uc_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_uc_r_s    <= 1'b0;
          end
      end


//--DLY FLG MC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mbpl_mc_r_s    <= 1'b0;
          end
        else if (c_mc_delay_cnt == P_MC_DELAY)
          begin
            c_mbpl_mc_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_mc_r_s    <= 1'b0;
          end
      end


//--DLY FLG DC Phase --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mbpl_dc_r_s    <= 1'b0;
          end
        else if (c_dc_delay_cnt == P_DC_DELAY)
          begin
            c_mbpl_dc_r_s    <= 1'b1;
          end
        else
          begin
            c_mbpl_dc_r_s    <= 1'b0;
          end
      end

//--MB Pulse with 0 delay --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_mbpl_psft_r_s   <= 1'b0;
            c_mbpl_pos_r_s    <= 1'b0;
            c_mbpl_skpmb_r_s  <= 1'b0;
          end
        else
          begin
            c_mbpl_psft_r_s   <= c_mbpl_ppl_s;
            c_mbpl_pos_r_s    <= c_mbpl_stg1_s;
            c_mbpl_skpmb_r_s  <= c_mbpl_stg1_skpmb_s;
          end
      end

endmodule
