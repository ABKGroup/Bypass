// ----------------------------------------------
// File: cmbfix.v
// Module: cmbfix
// Function:
// ----------------------------------------------

module cmbfix (
    clkdec,   
    rstdec_x, 
    c_pcpl_r_s,           //Picture Processing Start Pulse
    c_shdet_r,            //Slice Header Detected
    v_slclverr_r,         //VLD Non-Fatal-Error
    v_ferror_r,           //VLD Fatal-Error    
    c_pic_notcplt_r,      //Picture Not Complete
    c_mpg1_r,             //MPEG1(H)/MPEG2(L)
    c_pctv_mb_r,          //Picture Vertical Size
    c_pcth_mb_r,          //Picture Horizontal Size
    c_mb_fin_r,           //Final MB Position
    c_mbv_adr_p1_r,       //Now MB Vertical Position
    c_mbh_adr_p1_r,       //Now MB Horizontal Position
    c_mbv_adr_nxt_r,      //Next MB Vertical Position
    c_mbh_adr_nxt_r,      //Next MB Horizontal Position
    c_mb_nxt_fix_r,       //Next MB Fix
    c_skipslc_r_s,        //Slice Header Search
    c_mb_nferr_r,         //MB Non-Fatal-Error
    c_mb_ferr_r,          //MB Fatal-Error
    c_skpmb_r,            //Skip MB Command
    c_ccl_r,              //Conceal Command
    c_rvs_mbp_r           //MB Reverse Position Command
  );

    input        clkdec;       
    input        rstdec_x;     
    input        v_slclverr_r;   
    input        v_ferror_r;     
    input        c_pcpl_r_s;     
    input        c_pic_notcplt_r;
    input [6:0]  c_pctv_mb_r;    
    input [6:0]  c_pcth_mb_r;    
    input        c_shdet_r;      
    input        c_mpg1_r;       
    input [6:0]  c_mbv_adr_p1_r;  
    input [6:0]  c_mbh_adr_p1_r;  
    input        c_mb_fin_r;      
    input [7:0]  c_mbv_adr_nxt_r; 
    input [6:0]  c_mbh_adr_nxt_r; 
    input        c_mb_nxt_fix_r;  
    output       c_skipslc_r_s;   
    output [2:0] c_mb_nferr_r;    
    output       c_mb_ferr_r;     
    output       c_skpmb_r;       
    output       c_ccl_r;         
    output       c_rvs_mbp_r;     

    reg          c_skipslc_r_s;        //Slice Header Search
    reg [2:0]    c_mb_nferr_r;         //MB Non-Fatal-Error
    reg          c_mb_ferr_r;          //MB Fatal-Error
    reg          c_skpmb_r;            //Skip MB Command
    reg          c_ccl_r;              //Conceal Command
    reg          c_rvs_mbp_r;          //MB Reverse Position Command

    reg          c_def_r;              //Default(1 Step) Moving
    reg          c_ccl_vld_ferr_r;     //Conceal on VLD Fatal Error
    reg          c_def_msk_r;          //Default(1 Step) Moving

    reg          c_mb_nferr_i4_r;      //NFE4(internal):Default(1 Step) Moving
    reg          c_mb_nferr_i3_r;      //NFE3(internal):2 Step Over
    reg          c_mb_nferr_i2_r;      //NFE2(internal):2 Step Over(SH)
    reg          c_mb_nferr_i1_r;      //NFE1(internal):Backward
    reg          c_mb_nferr_i0_r;      //NFE0(internal):c_pic_notcplt_r

    reg          c_mb_ferr_i1_r;       //FE1(internal):2 Step Over(5-10)
    reg          c_mb_ferr_i0_r;       //FE0(internal):Default(1 Step) Moving

    reg          c_mb_nferr_i43f_r;    //NFE4or3(internal) Shift
    reg          c_mb_nferr_i21f_r;    //NFE2or1(internal) Shift
    reg          c_mb_nferr_i0f_r;     //NFE0(internal) Shift
    reg          c_mb_ferr_i10f_r;     //FE1or0(internal) Shift

    reg          c_pre_skipslc_r;      //(Pre)Slice Header Search
    reg          c_pre_skipslc_2_r;    //(Pre)Slice Header Search Shift

    wire [7:0]   c_mbv_adr_p2;         //Now MB Vertical Position + 1
    wire [7:0]   c_mbh_adr_p2;         //Now MB Horizontal Position + 1

    wire          c_mbv_nwp1_eq_nx;     //
    wire          c_mbv_nw_eq_nx;       //
    wire          c_mbv_nw_gt_nx;       //
    wire          c_mbv_nw_lt_nx;       //
    wire          c_mbv_nx_eq_mx;       //
    wire          c_mbv_nx_gt_mx;       //
    wire          c_mbv_nx_lt_mx;       //

    wire          c_mbh_nwp1_lt_nx;     //
    wire          c_mbh_nwp1_eq_nx;     //
    wire          c_mbh_nw_eq_nx;       //
    wire          c_mbh_nw_gt_nx;       //
    wire          c_mbh_nw_eq_mx;       //
    wire          c_mbh_nx_gt_mx;       //
    wire          c_mbh_nx_eq1;         //

    wire          c_mb_nferr_i4or3;    //NFE4or3(internal)
    wire          c_mb_nferr_i2or1;    //NFE2or1(internal)
    wire          c_mb_ferr_i1or0;     //FE1or0(internal)


    assign c_mbv_adr_p2 = {1'b0,c_mbv_adr_p1_r} + 1;
    assign c_mbh_adr_p2 = {1'b0,c_mbh_adr_p1_r} + 1;

    assign c_mbv_nwp1_eq_nx = (c_mbv_adr_p2 == c_mbv_adr_nxt_r)
      ? 1'b1 : 1'b0;
    assign c_mbv_nw_eq_nx = ({1'b0,c_mbv_adr_p1_r} == c_mbv_adr_nxt_r)
      ? 1'b1 : 1'b0;
    assign c_mbv_nw_gt_nx = ({1'b0,c_mbv_adr_p1_r} > c_mbv_adr_nxt_r)
      ? 1'b1 : 1'b0;
    assign c_mbv_nw_lt_nx = ({1'b0,c_mbv_adr_p1_r} < c_mbv_adr_nxt_r)
      ? 1'b1 : 1'b0;
    assign c_mbv_nx_eq_mx = (c_mbv_adr_nxt_r == {1'b0,c_pctv_mb_r})
      ? 1'b1 : 1'b0;
    assign c_mbv_nx_gt_mx = (c_mbv_adr_nxt_r > {1'b0,c_pctv_mb_r})
      ? 1'b1 : 1'b0;
    assign c_mbv_nx_lt_mx = (c_mbv_adr_nxt_r < {1'b0,c_pctv_mb_r})
      ? 1'b1 : 1'b0;

    assign c_mbh_nwp1_eq_nx = (c_mbh_adr_p2 == {1'b0,c_mbh_adr_nxt_r})
      ? 1'b1 : 1'b0;
    assign c_mbh_nwp1_lt_nx = (c_mbh_adr_p2 < {1'b0,c_mbh_adr_nxt_r})
      ? 1'b1 : 1'b0;
    assign c_mbh_nw_eq_nx = (c_mbh_adr_p1_r == c_mbh_adr_nxt_r)
      ? 1'b1 : 1'b0;
    assign c_mbh_nw_gt_nx = (c_mbh_adr_p1_r > c_mbh_adr_nxt_r)
      ? 1'b1 : 1'b0;
    assign c_mbh_nw_eq_mx = (c_mbh_adr_p1_r == c_pcth_mb_r)
      ? 1'b1 : 1'b0;
    assign c_mbh_nx_gt_mx = (c_mbh_adr_nxt_r > c_pcth_mb_r)
      ? 1'b1 : 1'b0;
    assign c_mbh_nx_eq1 = (c_mbh_adr_nxt_r == 7'h01)
      ? 1'b1 : 1'b0;


//-- Default(1 Step) Moving Mask --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_def_msk_r <= 1'b1;
          end
        else if (c_pcpl_r_s)
          begin
            c_def_msk_r <= 1'b1;
          end
        else if (c_shdet_r)
          begin
            c_def_msk_r <= 1'b0;
          end
        else
          begin
            c_def_msk_r <= c_def_msk_r;
          end
      end

//-- Conceal on VLD Fatal Error --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_ccl_vld_ferr_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_ccl_vld_ferr_r <= 1'b0;
          end
        else if (c_mb_nxt_fix_r)
          begin
            c_ccl_vld_ferr_r <= 1'b0;
          end
        else if (v_slclverr_r && v_ferror_r)
          begin
            c_ccl_vld_ferr_r <= 1'b1;
          end
        else
          begin
            c_ccl_vld_ferr_r <= c_ccl_vld_ferr_r;
          end
      end

//-- Default(1 Step) Moving --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)    
          begin
            c_def_r <= 1'b0;
          end
        else if (c_pcpl_r_s || c_def_msk_r)
          begin
            c_def_r <= 1'b0;
          end
        else if ((c_mbv_nw_eq_nx && c_mbh_nwp1_eq_nx)
                 || ((c_mpg1_r || (!c_mpg1_r && c_shdet_r))
                     && c_mbv_nwp1_eq_nx
                     && c_mbh_nw_eq_mx
                     && c_mbh_nx_eq1))
          begin
            c_def_r <= 1'b1;
          end
        else
          begin
            c_def_r <= 1'b0;
          end
      end

//-- Skip MB  --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            c_skpmb_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_skpmb_r <= 1'b0;
          end
        else if (!c_shdet_r
                 && ((c_mbv_nw_eq_nx && c_mbh_nwp1_lt_nx)
                     || ((c_mbv_nw_lt_nx
                          && (c_mbv_nx_eq_mx || c_mbv_nx_lt_mx))
                         && !(c_mbv_nwp1_eq_nx
                              && c_mbh_nw_eq_mx
                              && c_mbh_nx_eq1))))
          begin
            c_skpmb_r <= 1'b1;
          end
        else
          begin
            c_skpmb_r <= 1'b0;
          end
      end

//-- Conceal --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_ccl_r <= 1'b0;
          end
        else if (c_pcpl_r_s 
                 || ((c_def_r || c_rvs_mbp_r)
                     && !(c_ccl_vld_ferr_r || c_pic_notcplt_r)))
          begin
            c_ccl_r <= 1'b0;
          end
        else if (c_ccl_vld_ferr_r || c_pic_notcplt_r
                 || (c_mb_nxt_fix_r
                     && (c_shdet_r
                         && ((c_mbv_nw_eq_nx && c_mbh_nwp1_lt_nx)
                             || (c_mbv_nw_lt_nx && !c_mbh_nx_eq1)))

                     || (!c_shdet_r && (c_mbv_nw_lt_nx && c_mbv_nx_gt_mx))
                     || (c_shdet_r
                         && ((c_mbv_nw_lt_nx
                              && (c_mbv_nx_eq_mx || c_mbv_nx_gt_mx)
                              && c_mbh_nx_gt_mx)
                             || (c_mbv_nw_eq_nx
                                 && (c_mbv_nx_eq_mx || c_mbv_nx_lt_mx)
                                 && c_mbh_nwp1_lt_nx
                                 && c_mbh_nx_gt_mx)))))
          begin
            c_ccl_r <= 1'b1;
          end
        else
          begin
            c_ccl_r <= c_ccl_r;
          end
      end

//-- Backward --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_rvs_mbp_r <= 1'b0;

          end
        else if (c_pcpl_r_s
                 || (c_def_r || c_skpmb_r)
                 || (c_ccl_vld_ferr_r || c_pic_notcplt_r))
          begin
            c_rvs_mbp_r <= 1'b0;
          end
        else if ((c_mbv_nw_gt_nx
                  || (c_mbv_nw_eq_nx && c_mbh_nw_gt_nx)))
          begin
             c_rvs_mbp_r <= ~c_ccl_vld_ferr_r;
          end
        else
          begin
            c_rvs_mbp_r <= c_rvs_mbp_r;
          end
      end

//-- Fatal Error(internal:1) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            c_mb_ferr_i1_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_mb_ferr_i1_r <= 1'b0;
          end
        else if ((!c_shdet_r 
                  && (c_mbv_nw_lt_nx && c_mbv_nx_gt_mx))
                 || (c_shdet_r
                     && ((c_mbv_nw_lt_nx
                          && (c_mbv_nx_eq_mx || c_mbv_nx_gt_mx)
                          && (c_mbh_nx_gt_mx))
                         || (c_mbv_nw_eq_nx
                             && (c_mbv_nx_eq_mx || c_mbv_nx_lt_mx)
                             && c_mbh_nwp1_lt_nx
                             && c_mbh_nx_gt_mx))))
          begin
            c_mb_ferr_i1_r <= 1'b1;
          end
        else
          begin
            c_mb_ferr_i1_r <= c_mb_ferr_i1_r;
          end
      end

//-- Fatal Error(internal:0) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mb_ferr_i0_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_mb_ferr_i0_r <= 1'b0;
          end
        else if (c_mb_fin_r
                 && ((!c_shdet_r && c_mbh_nx_eq1)
                     || (c_shdet_r && c_mbh_nx_gt_mx)))
          begin
            c_mb_ferr_i0_r <= 1'b1;
          end
        else
          begin
            c_mb_ferr_i0_r <= c_mb_ferr_i0_r;
          end
      end


//-- NonFatal Error
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_mb_nferr_i4_r <= 1'b0;
          end
        else if (c_pcpl_r_s || c_mb_fin_r)
          begin
            c_mb_nferr_i4_r <= 1'b0;
          end
        else if ((!c_mpg1_r 
                  && !c_shdet_r
                  && c_mbv_nwp1_eq_nx
                  && c_mbh_nw_eq_mx
                  && c_mbh_nx_eq1)
                 || (c_shdet_r
                     && c_mbv_nw_eq_nx
                     && c_mbh_nw_eq_mx
                     && c_mbh_nx_gt_mx))
          begin
            c_mb_nferr_i4_r <= 1'b1;
          end
        else
          begin
            c_mb_nferr_i4_r <= c_mb_nferr_i4_r;
          end
      end

//-- NonFatal Error(internal:3) --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_mb_nferr_i3_r <= 1'b0;
          end
        else if (c_pcpl_r_s || c_mb_fin_r)
          begin
            c_mb_nferr_i3_r <= 1'b0;
          end
        else if (!c_shdet_r  
                 && !c_mpg1_r
                 && c_mbv_nw_lt_nx
                 && (c_mbv_nx_eq_mx || c_mbv_nx_lt_mx)
                 && !(c_mbv_nwp1_eq_nx
                      && c_mbh_nw_eq_mx
                      && c_mbh_nx_eq1))
          begin
            c_mb_nferr_i3_r <= 1'b1;
          end
        else
          begin
            c_mb_nferr_i3_r <= c_mb_nferr_i3_r;
          end
      end

//-- NonFatal Error
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_mb_nferr_i2_r <= 1'b0;
          end
        else if (c_pcpl_r_s || c_mb_fin_r)
          begin
            c_mb_nferr_i2_r <= 1'b0;
          end
        else if (c_shdet_r 
                 && ((c_mbv_nw_eq_nx && c_mbh_nwp1_lt_nx)
                     || c_mbv_nw_lt_nx)
                 && !(c_mbv_nwp1_eq_nx
                      && c_mbh_nw_eq_mx
                      && c_mbh_nx_eq1))
          begin
            c_mb_nferr_i2_r <= 1'b1;
          end
        else
          begin
            c_mb_nferr_i2_r <= 1'b0;
          end
      end

//-- NonFatal Error(internal:1) 
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_mb_nferr_i1_r <= 1'b0;
          end
        else if (c_pcpl_r_s || c_mb_fin_r)
          begin
            c_mb_nferr_i1_r <= 1'b0;
          end
        else if ((c_mbv_nw_gt_nx 
                  || (c_mbv_nw_eq_nx && c_mbh_nw_gt_nx)))
          begin
            c_mb_nferr_i1_r <= 1'b1;
          end
        else
          begin
            c_mb_nferr_i1_r <= 1'b0;
          end
      end

//-- NonFatal Error(internal:0) 
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)      
          begin
            c_mb_nferr_i0_r <= 1'b0;
          end
        else if (c_pcpl_r_s || c_mb_fin_r)
          begin
            c_mb_nferr_i0_r <= 1'b0;
          end
        else if (c_pic_notcplt_r)
          begin
            c_mb_nferr_i0_r <= 1'b1;
          end
        else
          begin
            c_mb_nferr_i0_r <= 1'b0;
          end
      end

//-- (Pre)Slice Header Search --
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_pre_skipslc_r <= 1'b0;
          end
        else if (c_pcpl_r_s)
          begin
            c_pre_skipslc_r <= 1'b0;
          end
        else if (c_mb_fin_r
                 && ((!c_shdet_r && c_mbh_nx_eq1)
                     || (c_shdet_r && c_mbh_nx_gt_mx))
                 || (!c_shdet_r && (c_mbv_nw_lt_nx && c_mbv_nx_gt_mx))
                 || (c_shdet_r
                     && ((c_mbv_nw_lt_nx
                          && (c_mbv_nx_eq_mx || c_mbv_nx_gt_mx)
                          && (c_mbh_nx_gt_mx))
                         || (c_mbv_nw_eq_nx
                             && (c_mbv_nx_eq_mx || c_mbv_nx_lt_mx)
                             && c_mbh_nwp1_lt_nx
                             && c_mbh_nx_gt_mx))))
          begin
            c_pre_skipslc_r <= 1'b1;
          end
        else
          begin
            c_pre_skipslc_r <= c_pre_skipslc_r;
          end
      end

//-- Slice Header Search 
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)
          begin
            c_pre_skipslc_2_r <= 1'b1;
            c_skipslc_r_s     <= 1'b0;
          end
        else
          begin
            c_pre_skipslc_2_r <= c_pre_skipslc_r;
            c_skipslc_r_s     <= c_pre_skipslc_r & ~c_pre_skipslc_2_r;
          end
      end

//-- Fatal/NonFatal Error Shift
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)     
          begin
            c_mb_nferr_i43f_r <= 1'b0;
            c_mb_nferr_i21f_r <= 1'b0;
            c_mb_nferr_i0f_r  <= 1'b0;
            c_mb_ferr_i10f_r  <= 1'b0;
          end
        else
          begin
            c_mb_nferr_i43f_r <= c_mb_nferr_i4or3;
            c_mb_nferr_i21f_r <= c_mb_nferr_i2or1;
            c_mb_nferr_i0f_r  <= c_mb_nferr_i0_r;
            c_mb_ferr_i10f_r  <= c_mb_ferr_i1or0;
          end
      end
    assign c_mb_nferr_i4or3 = c_mb_nferr_i4_r | c_mb_nferr_i3_r;
    assign c_mb_nferr_i2or1 = c_mb_nferr_i2_r | c_mb_nferr_i1_r;
    assign c_mb_ferr_i1or0  = c_mb_ferr_i1_r  | c_mb_ferr_i0_r;

//-- Fatal/NonFatal Error Out
    always @(posedge clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)   
          begin
            c_mb_nferr_r[2] <= 1'b0;
            c_mb_nferr_r[1] <= 1'b0;
            c_mb_nferr_r[0] <= 1'b0;
            c_mb_ferr_r     <= 1'b0;
          end
        else
          begin
            c_mb_nferr_r[2] <= c_mb_nferr_i4or3 & ~c_mb_nferr_i43f_r;
            c_mb_nferr_r[1] <= c_mb_nferr_i2or1 & ~c_mb_nferr_i21f_r;
            c_mb_nferr_r[0] <= c_mb_nferr_i0_r  & ~c_mb_nferr_i0f_r;
            c_mb_ferr_r     <= c_mb_ferr_i1or0  & ~c_mb_ferr_i10f_r;
          end
      end
endmodule

