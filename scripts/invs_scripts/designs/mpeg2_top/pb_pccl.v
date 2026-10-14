// ----------------------------------------------
// File: pb_pccl.v
// Module: pb_pccl
// Function: Parameter Conceal
// ----------------------------------------------

module pb_pccl
  (
    clkdec,           
    rstdec_x,         
    v_fstfwdvech_r,       //[12:0]Mton Vctr 1st Fwd H
    v_fstfwdvecv_r,       //[8:0] Mton Vctr 1st Fwd V
    v_fstbwdvech_r,       //[12:0]Mton Vctr 1st Bwd H
    v_fstbwdvecv_r,       //[8:0] Mton Vctr 1st Bwd V
    v_sndfwdvech_r,       //[12:0]Mton Vctr 2nt Fwd H
    v_sndfwdvecv_r,       //[8:0] Mton Vctr 2nt Fwd V
    v_sndbwdvech_r,       //[12:0]Mton Vctr 2nd Bwd H
    v_sndbwdvecv_r,       //[8:0] Mton Vctr 2nd Bwd V
    c_ccl_r,              //Conceal Command
    v_motion_type_r,      //[1:0]Motion Type
    c_pred_forward_r,     //Prediction Forward
    c_pred_backward_r,    //Prediction Backward
    c_mbtyp_0_r,          //MB Type 0(Intra)
    c_pstr_r,             //[1:0]Picture Structure
    c_fldsel1_fix1_r,     //Mton Vert Fld Sel 1(MPEG Fix)
    c_fldsel2_fix1_r,     //Mton Vert Fld Sel 2(MPEG Fix)
    c_fldsel3_fix1_r,     //Mton Vert Fld Sel 3(MPEG Fix)
    c_fldsel4_fix1_r,     //Mton Vert Fld Sel 4(MPEG Fix)
    c_hsval_r,            //[11:0]Horizontal Size Value
    c_vsval_r,            //[11:0]Vertical Size Value
    g_hsdc_r,               //[6:0]
    g_vsdc_r,               //[6:0]
    c_pic_codtyp_r,         //[2:0]
    n_pic_codtyp_reffld1_r, //[2:0]
    n_pic_codtyp_reffld2_r, //[2:0]
    n_pic_codtyp_reffld3_r, //[2:0]
    n_pic_codtyp_reffld4_r, //[2:0]
    p_pred_forward_fix_r,  //Prediction Forward (CCL Fix)
    p_pred_backward_fix_r, //Prediction Backward (CCL Fix)
    p_mbtyp_0_fix_r,       //MB Type 0(Intra) (CCL Fix)
    p_mttyp_fix_r,         //[1:0]Motion Type (CCL Fix)
    p_fstfwdvech_fix_r,    //[12:0]Mton Vctr 1st Fwd H (CCL Fix)
    p_fstfwdvecv_fix_r,    //[8:0] Mton Vctr 1st Fwd V (CCL Fix)
    p_fstbwdvech_fix_r,    //[12:0]Mton Vctr 1st Bwd H (CCL Fix)
    p_fstbwdvecv_fix_r,    //[8:0] Mton Vctr 1st Bwd V (CCL Fix)
    p_sndfwdvech_fix_r,    //[12:0]Mton Vctr 2nt Fwd H (CCL Fix)
    p_sndfwdvecv_fix_r,    //[8:0] Mton Vctr 2nt Fwd V (CCL Fix
    p_sndbwdvech_fix_r,    //[12:0]Mton Vctr 2nd Bwd H (CCL Fix)
    p_sndbwdvecv_fix_r,    //[8:0]Mton Vctr 2nd Bwd V (CCL Fix)
    p_fldsel1_fix2_r,      //Mton Vert Fld Sel 1 (MPEG,CCL Fix)
    p_fldsel2_fix2_r,      //Mton Vert Fld Sel 2 (MPEG,CCL Fix)
    p_fldsel3_fix2_r,      //Mton Vert Fld Sel 3 (MPEG,CCL Fix)
    p_fldsel4_fix2_r,      //Mton Vert Fld Sel 4 (MPEG,CCL Fix)
    p_hdtvh_r              //HDTV Flag
  );


    input         clkdec;           
    input        rstdec_x;         
    input        c_ccl_r;            
    input [12:0] v_fstfwdvech_r;     
    input [8:0]  v_fstfwdvecv_r;     
    input [12:0] v_fstbwdvech_r;     
    input [8:0]  v_fstbwdvecv_r;     
    input [12:0] v_sndfwdvech_r;     
    input [8:0]  v_sndfwdvecv_r;     
    input [12:0] v_sndbwdvech_r;     
    input [8:0]  v_sndbwdvecv_r;     
    input        c_mbtyp_0_r;        
    input        c_pred_forward_r;   
    input        c_pred_backward_r;  
    input [1:0]  v_motion_type_r;    
    input [2:0]  c_pic_codtyp_r;        
    input [2:0]  n_pic_codtyp_reffld1_r;
    input [2:0]  n_pic_codtyp_reffld2_r;
    input [2:0]  n_pic_codtyp_reffld3_r;
    input [2:0]  n_pic_codtyp_reffld4_r;
    input [1:0]  c_pstr_r;            
    input        c_fldsel1_fix1_r;    
    input        c_fldsel2_fix1_r;    
    input        c_fldsel3_fix1_r;    
    input        c_fldsel4_fix1_r;    
    input [11:0] c_hsval_r;           
    input [11:0] c_vsval_r;           
    input [6:0]  g_hsdc_r;            
    input [6:0]  g_vsdc_r;            

    output [12:0] p_fstfwdvech_fix_r; 
    output [8:0]  p_fstfwdvecv_fix_r; 
    output [12:0] p_fstbwdvech_fix_r; 
    output [8:0]  p_fstbwdvecv_fix_r; 
    output [12:0] p_sndfwdvech_fix_r; 
    output [8:0]  p_sndfwdvecv_fix_r; 
    output [12:0] p_sndbwdvech_fix_r; 
    output [8:0]  p_sndbwdvecv_fix_r; 
    output        p_mbtyp_0_fix_r;    
    output        p_pred_forward_fix_r;
    output        p_pred_backward_fix_r;
    output [1:0]  p_mttyp_fix_r;        
    output        p_fldsel1_fix2_r;     
    output        p_fldsel2_fix2_r;     
    output        p_fldsel3_fix2_r;     
    output        p_fldsel4_fix2_r;     
    output        p_hdtvh_r;            

    reg        p_pred_forward_fix_r;  //Prediction Forward (CCL Fix)
    reg        p_pred_backward_fix_r; //Prediction Backward (CCL Fix)
    reg        p_mbtyp_0_fix_r;       //MB Type 0(Intra) (CCL Fix)
    reg [1:0]  p_mttyp_fix_r;         //Motion Type (CCL Fix)
    reg [12:0] p_fstfwdvech_fix_r;    //Mton Vctr 1st Fwd H (CCL Fix)
    reg [8:0]  p_fstfwdvecv_fix_r;    //Mton Vctr 1st Fwd V (CCL Fix)
    reg [12:0] p_fstbwdvech_fix_r;    //Mton Vctr 1st Bwd H (CCL Fix)
    reg [8:0]  p_fstbwdvecv_fix_r;    //Mton Vctr 1st Bwd V (CCL Fix)
    reg [12:0] p_sndfwdvech_fix_r;    //Mton Vctr 2nt Fwd H (CCL Fix)
    reg [8:0]  p_sndfwdvecv_fix_r;    //Mton Vctr 2nt Fwd V (CCL Fix)
    reg [12:0] p_sndbwdvech_fix_r;    //Mton Vctr 2nd Bwd H (CCL Fix)
    reg [8:0]  p_sndbwdvecv_fix_r;    //Mton Vctr 2nd Bwd V (CCL Fix)
    reg        p_fldsel1_fix2_r;      //Mton Vert Fld Sel 1 (MPEG,CCL Fix)
    reg        p_fldsel2_fix2_r;      //Mton Vert Fld Sel 2 (MPEG,CCL Fix)
    reg        p_fldsel3_fix2_r;      //Mton Vert Fld Sel 3 (MPEG,CCL Fix)
    reg        p_fldsel4_fix2_r;      //Mton Vert Fld Sel 4 (MPEG,CCL Fix)
    reg        p_hdtvh_r;             //HDTV Flag


    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_fstfwdvech_fix_r <= 13'h0000;
          end
        else if (c_ccl_r)
          begin
            p_fstfwdvech_fix_r <= 13'h0000;
          end
        else
          begin
            p_fstfwdvech_fix_r <= v_fstfwdvech_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_fstfwdvecv_fix_r <= 9'h000;
          end
        else if (c_ccl_r)
          begin
            p_fstfwdvecv_fix_r <= 9'h000;
          end
        else
          begin
            p_fstfwdvecv_fix_r <= v_fstfwdvecv_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_fstbwdvech_fix_r <= 13'h0000;
          end
        else if (c_ccl_r)
          begin
            p_fstbwdvech_fix_r <= 13'h0000;
          end
        else
          begin
            p_fstbwdvech_fix_r <= v_fstbwdvech_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_fstbwdvecv_fix_r <= 9'h000;
          end
        else if (c_ccl_r)
          begin
            p_fstbwdvecv_fix_r <= 9'h000;
          end
        else
          begin
            p_fstbwdvecv_fix_r <= v_fstbwdvecv_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_sndfwdvech_fix_r <= 13'h0000;
          end
        else if (c_ccl_r)
          begin
            p_sndfwdvech_fix_r <= 13'h0000;
          end
        else
          begin
            p_sndfwdvech_fix_r <= v_sndfwdvech_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_sndfwdvecv_fix_r <= 9'h000;
          end
        else if (c_ccl_r)
          begin
            p_sndfwdvecv_fix_r <= 9'h000;
          end
        else
          begin
            p_sndfwdvecv_fix_r <= v_sndfwdvecv_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_sndbwdvech_fix_r <= 13'h0000;
          end
        else if (c_ccl_r)
          begin
            p_sndbwdvech_fix_r <= 13'h0000;
          end
        else
          begin
            p_sndbwdvech_fix_r <= v_sndbwdvech_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_sndbwdvecv_fix_r <= 9'h000;
          end
        else if (c_ccl_r)
          begin
            p_sndbwdvecv_fix_r <= 9'h000;
          end
        else
          begin
            p_sndbwdvecv_fix_r <= v_sndbwdvecv_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_mbtyp_0_fix_r <= 1'b0;
          end
        else if (c_ccl_r)
          begin
            p_mbtyp_0_fix_r <= 1'b0;
          end
        else
          begin
            p_mbtyp_0_fix_r <= c_mbtyp_0_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_pred_forward_fix_r <= 1'b0;
          end
        else if (c_ccl_r)
          begin
            p_pred_forward_fix_r <= 1'b1;
          end
        else
          begin
            p_pred_forward_fix_r <= c_pred_forward_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_pred_backward_fix_r <= 1'b0;
          end
        else if (c_ccl_r)
          begin
            p_pred_backward_fix_r <= 1'b0;
          end
        else
          begin
            p_pred_backward_fix_r <= c_pred_backward_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)                
          begin
            p_mttyp_fix_r <= 2'b00;
          end
        else if (c_ccl_r)
          begin
            if (c_pstr_r==2'b11)   
              begin
                p_mttyp_fix_r <= 2'b10;
              end
            else                    
              begin
                p_mttyp_fix_r <= 2'b01;
              end
          end
        else
          begin
            p_mttyp_fix_r <= v_motion_type_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            p_fldsel1_fix2_r <= 1'b0;
          end
        else if (c_ccl_r) 
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld1_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    p_fldsel1_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel1_fix2_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    p_fldsel1_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel1_fix2_r <= 1'b0;
                  end
              end
          end
        else
          begin
            p_fldsel1_fix2_r <= c_fldsel1_fix1_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x)  
          begin
            p_fldsel2_fix2_r <= 1'b0;
          end
        else if (c_ccl_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld2_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    p_fldsel2_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel2_fix2_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    p_fldsel2_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel2_fix2_r <= 1'b0;
                  end
              end
          end
        else
          begin
            p_fldsel2_fix2_r <= c_fldsel2_fix1_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            p_fldsel3_fix2_r <= 1'b0;
          end
        else if (c_ccl_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld3_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    p_fldsel3_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel3_fix2_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    p_fldsel3_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel3_fix2_r <= 1'b0;
                  end
              end
          end
        else
          begin
            p_fldsel3_fix2_r <= c_fldsel3_fix1_r;
          end
      end

    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            p_fldsel4_fix2_r <= 1'b0;
          end
        else if (c_ccl_r)
          begin
            if ((c_pic_codtyp_r==3'b010) &&
                (n_pic_codtyp_reffld4_r==3'b001))
              begin
                if (c_pstr_r==2'b01)
                  begin
                    p_fldsel4_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel4_fix2_r <= 1'b0;
                  end
              end
            else
              begin
                if (c_pstr_r==2'b10)
                  begin
                    p_fldsel4_fix2_r <= 1'b1;
                  end
                else
                  begin
                    p_fldsel4_fix2_r <= 1'b0;
                  end
              end
          end
        else
          begin
            p_fldsel4_fix2_r <= c_fldsel4_fix1_r;
          end
      end


    always @(posedge  clkdec or negedge rstdec_x)
      begin
        if (!rstdec_x) 
          begin
            p_hdtvh_r <= 1'b0;
          end
        else if ((c_hsval_r>{g_hsdc_r,4'h0}) ||
                 (c_vsval_r>{g_vsdc_r,4'h0}))
          begin
            p_hdtvh_r <= 1'b1;
          end
        else
          begin
            p_hdtvh_r <= 1'b0;
          end
      end

endmodule

