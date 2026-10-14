// ----------------------------------------------
// File: vld_outvec.v
// Module: vld_outvec
// Function:generate motion_vector from VLD
// ----------------------------------------------

module vld_outvec(
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    v_mbhend_ff_r_s, 
    v_mbpl_skpmb_r_s,
    v_picture_coding_type, 
    v_pmv_1, v_pmv_2, 
    v_pmv_3, v_pmv_4,
    v_pmv_5, v_pmv_6, 
    v_pmv_7, v_pmv_8,
    v_fstfwdvech_b_r, 
    v_fstfwdvecv_b_r, 
    v_fstbwdvech_b_r, 
    v_fstbwdvecv_b_r,
    v_sndfwdvech_b_r, 
    v_sndfwdvecv_b_r,
    v_sndbwdvech_b_r, 
    v_sndbwdvecv_b_r,
    v_ofstfwdvech_r, 
    v_ofstfwdvecv_r,
    v_ofstbwdvech_r, 
    v_ofstbwdvecv_r,
    v_osndfwdvech_r, 
    v_osndfwdvecv_r,
    v_osndbwdvech_r, 
    v_osndbwdvecv_r
);

input clkdec;                // VLD clock
input rstdec_x;              // Async reset
input g_swrst_r_n;             // SW reset
input v_mbhend_ff_r_s;         // renewal plus
input v_mbpl_skpmb_r_s;        // renewal plus (skip)
input [2:0] v_picture_coding_type; // Picture_type 
input [12:0] v_pmv_1;          // befor PMV(1)
input [8:0] v_pmv_2;          // befor PMV(2)
input [12:0] v_pmv_3;          // befor PMV(3)
input [8:0] v_pmv_4;          // befor PMV(4)
input [12:0] v_pmv_5;          // befor PMV(5)
input [8:0] v_pmv_6;          // befor PMV(6)
input [12:0] v_pmv_7;          // befor PMV(7)
input [8:0] v_pmv_8;          // befor PMV(8)
input [12:0] v_fstfwdvech_b_r; // now Vector(1)
input [8:0] v_fstfwdvecv_b_r; // now Vector(2)
input [12:0] v_fstbwdvech_b_r; // now Vector(3)
input [8:0] v_fstbwdvecv_b_r; // now Vector(4)
input [12:0] v_sndfwdvech_b_r; // now Vector(5)
input [8:0] v_sndfwdvecv_b_r; // now Vector(6)
input [12:0] v_sndbwdvech_b_r; // now Vector(7)
input [8:0] v_sndbwdvecv_b_r; // now Vector(8)
output [12:0] v_ofstfwdvech_r;  // Output Vector(1)
output [8:0] v_ofstfwdvecv_r;  // Output Vector(2)
output [12:0] v_ofstbwdvech_r;  // Output Vector(3)
output [8:0] v_ofstbwdvecv_r;  // Output Vector(4)
output [12:0] v_osndfwdvech_r;  // Output Vector(5)
output [8:0] v_osndfwdvecv_r;  // Output Vector(6)
output [12:0] v_osndbwdvech_r;  // Output Vector(7)
output [8:0] v_osndbwdvecv_r;  // Output Vector(8)

reg [12:0] v_ofstfwdvech_r;  // Output Vector(1)
reg [8:0] v_ofstfwdvecv_r;  // Output Vector(2)
reg [12:0] v_ofstbwdvech_r;  // Output Vector(3)
reg [8:0] v_ofstbwdvecv_r;  // Output Vector(4)
reg [12:0] v_osndfwdvech_r;  // Output Vector(5)
reg [8:0] v_osndfwdvecv_r;  // Output Vector(6)
reg [12:0] v_osndbwdvech_r;  // Output Vector(7)
reg [8:0] v_osndbwdvecv_r;  // Output Vector(8)

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_ofstfwdvech_r <= 13'h0000;
        v_ofstfwdvecv_r <= 9'h000;
        v_ofstbwdvech_r <= 13'h0000;
        v_ofstbwdvecv_r <= 9'h000;
        v_osndfwdvech_r <= 13'h0000;
        v_osndfwdvecv_r <= 9'h000;
        v_osndbwdvech_r <= 13'h0000;
        v_osndbwdvecv_r <= 9'h000; 
      end
    else
      begin
        if(g_swrst_r_n == 1'b0) 
          begin
            v_ofstfwdvech_r <= 13'h0000;
            v_ofstfwdvecv_r <= 9'h000;
            v_ofstbwdvech_r <= 13'h0000;
            v_ofstbwdvecv_r <= 9'h000;
            v_osndfwdvech_r <= 13'h0000;
            v_osndfwdvecv_r <= 9'h000;
            v_osndbwdvech_r <= 13'h0000;
            v_osndbwdvecv_r <= 9'h000; 
          end
        else
          begin
            if(v_mbpl_skpmb_r_s == 1'b1) 
              begin
                if(v_picture_coding_type == 3'b010) 
                  begin
                    v_ofstfwdvech_r <= 13'h0000;
                    v_ofstfwdvecv_r <= 9'h000;
                    v_ofstbwdvech_r <= 13'h0000;
                    v_ofstbwdvecv_r <= 9'h000;
                    v_osndfwdvech_r <= 13'h0000;
                    v_osndfwdvecv_r <= 9'h000;
                    v_osndbwdvech_r <= 13'h0000;
                    v_osndbwdvecv_r <= 9'h000;
                  end
                else if(v_picture_coding_type == 3'b011)
                  begin
                    v_ofstfwdvech_r <= v_pmv_1;
                    v_ofstfwdvecv_r <= v_pmv_2;
                    v_ofstbwdvech_r <= v_pmv_3;
                    v_ofstbwdvecv_r <= v_pmv_4;
                    v_osndfwdvech_r <= v_pmv_5;
                    v_osndfwdvecv_r <= v_pmv_6;
                    v_osndbwdvech_r <= v_pmv_7;
                    v_osndbwdvecv_r <= v_pmv_8;
                  end
                else
                  begin
                    v_ofstfwdvech_r <= v_fstfwdvech_b_r;
                    v_ofstfwdvecv_r <= v_fstfwdvecv_b_r;
                    v_ofstbwdvech_r <= v_fstbwdvech_b_r;
                    v_ofstbwdvecv_r <= v_fstbwdvecv_b_r;
                    v_osndfwdvech_r <= v_sndfwdvech_b_r;
                    v_osndfwdvecv_r <= v_sndfwdvecv_b_r;
                    v_osndbwdvech_r <= v_sndbwdvech_b_r;
                    v_osndbwdvecv_r <= v_sndbwdvecv_b_r;
                  end
              end
            else if(v_mbhend_ff_r_s == 1'b1) // end-deocde MB
              begin
                v_ofstfwdvech_r <= v_fstfwdvech_b_r;
                v_ofstfwdvecv_r <= v_fstfwdvecv_b_r;
                v_ofstbwdvech_r <= v_fstbwdvech_b_r;
                v_ofstbwdvecv_r <= v_fstbwdvecv_b_r;
                v_osndfwdvech_r <= v_sndfwdvech_b_r;
                v_osndfwdvecv_r <= v_sndfwdvecv_b_r;
                v_osndbwdvech_r <= v_sndbwdvech_b_r;
                v_osndbwdvecv_r <= v_sndbwdvecv_b_r;
              end
            else
              begin
                v_ofstfwdvech_r <= v_ofstfwdvech_r;
                v_ofstfwdvecv_r <= v_ofstfwdvecv_r;
                v_ofstbwdvech_r <= v_ofstbwdvech_r;
                v_ofstbwdvecv_r <= v_ofstbwdvecv_r; 
                v_osndfwdvech_r <= v_osndfwdvech_r;
                v_osndfwdvecv_r <= v_osndfwdvecv_r;
                v_osndbwdvech_r <= v_osndbwdvech_r;
                v_osndbwdvecv_r <= v_osndbwdvecv_r;
              end
          end   
      end 
  end


endmodule

