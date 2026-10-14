// ----------------------------------------------
// File: vld_genvec.v
// Module: vld_genvec
// Function:generate motion_vector from VLD
// ----------------------------------------------

module vld_genvec(
    v_f_code, 
    v_motion_code, 
    v_motion_residual, 
    v_inpmv, 
    clkdec, 
    rstdec_x, 
    g_swrst_r_n, 
    v_vector
);

input  [3:0] v_f_code;          // f_code(4bit)
input  [5:0] v_motion_code;     // motion_code(6bit)
input  [7:0] v_motion_residual; // motion_residual(8bit)
input [12:0] v_inpmv;           // input PMV data(13bit)
input clkdec;    // VLD clock
input rstdec_x;  // Reset
input g_swrst_r_n; // SW reset
output [12:0] v_vector;         // vector(horizontal:13bit,vertical:9bit)

wire [3:0] v_r_size;              // <= f_code-1(4bit)
wire [8:0] v_f;                   // <= 1<<r_size(9bit)
wire [12:0] v_f16;                // <= (16*f) (13bit)
wire [12:0] v_high;               // <= (16*f)-1 (13bit)
wire [12:0] v_low;                // <= (-(16*f)) (13bit)
wire [12:0] v_low_n;              // <= -(-(16*f)) (13bit)
wire [13:0] v_range;              // <=(32*f) (14bit)
wire [13:0] v_prediction;         // [14]:v_inpmv[13] 
wire [4:0] v_abs_motion_code_1;   // <= Abs(motion_code)-1 (5bit)
wire [12:0] v_f_abs_motion_code_1; // <= (Abs(motion_code)-1)*f (13bit)
wire [8:0] v_motion_residual_1;   // <= motion_residual+1 (8bit) 2004.3.16
reg  [13:0] v_vector_n;           // abs(vector)(13bit)
wire [13:0] v_vector_b;           // output vector (14bit)
wire [13:0] v_delta_b;            // [13]:signed,[12:0]:data 
wire [12:0] v_vector;             // output vector (13bit)

reg [13:0] v_vector_14;           // output vector (14bit)
reg [4:0] v_abs_motion_code;      // Abs(motion_code) (5bit)
reg [13:0] v_delta;               // [13]:signed,[12:0]:data 
reg [13:0] v_delta_r;             // [13]:signed,[12:0]:data 


assign v_r_size = v_f_code - 4'h1; //  0 <= v_r_size <= 9
assign v_f = 9'h001 << v_r_size; // 1 <= v_f <= 1000000000(512)
assign v_f16 =  v_f << 4;   // 16*f 
assign v_high = v_f16 - 13'h0001; //(16*f)-1
assign v_low = ~v_f16 + 13'h0001; //((-16)*f)
assign v_range = v_f16 << 1;      //(32*f)

always @(v_motion_code)
  begin
    case(v_motion_code[5])   
      1'b1:      
        begin
          v_abs_motion_code = ~v_motion_code[4:0] + 5'd1; 
        end
      default:  
        begin
          v_abs_motion_code = v_motion_code[4:0];
        end
    endcase
  end

assign v_abs_motion_code_1 = v_abs_motion_code - 5'h01; 
assign v_f_abs_motion_code_1 = v_abs_motion_code_1 << v_r_size; 
assign v_motion_residual_1 = v_motion_residual + 1; 
assign v_delta_b = v_f_abs_motion_code_1 + v_motion_residual_1;

always@ (v_f or v_motion_code or v_delta_b)
  begin
    if((v_f == 9'd1) || (v_motion_code == 6'h00))
      begin
        v_delta = {{8{v_motion_code[5]}},v_motion_code}; 
      end
    else
      begin
        if(v_motion_code[5]==1'b0) 
          begin
            v_delta = v_delta_b;   
          end
        else
          begin
            v_delta = ~v_delta_b + 14'd1; 
          end
      end
  end

always @(posedge clkdec or negedge rstdec_x)
  begin
    if(rstdec_x == 1'b0) 
      begin
        v_delta_r <= 14'h0000;
      end
    else if(g_swrst_r_n == 1'b0) 
      begin
        v_delta_r <= 14'h0000;
      end
    else
      begin
        v_delta_r <= v_delta;
      end
  end

assign v_prediction = {v_inpmv[12], v_inpmv}; 
assign v_vector_b = v_prediction + v_delta_r; 

assign v_low_n = ~v_low + 13'h0001;  

always @(v_vector_b)
  begin
    if(v_vector_b[13] == 1'b1) 
      begin
        v_vector_n = ~v_vector_b + 14'h0001;
      end
    else
      begin
        v_vector_n = v_vector_b;
      end
  end

always @(v_vector_b  or v_range or v_high or v_low_n or v_vector_n)
  begin
    if((v_vector_n > {1'b0, v_low_n}) 
          && (v_vector_b[13] == 1'b1)) 
      begin
        v_vector_14 = v_vector_b + {1'b0, v_range}; 
      end
    else
      begin
        if((v_vector_n > {1'b0, v_high}) 
              && (v_vector_b[13] == 1'b0)) 
          begin
            v_vector_14 = v_vector_b - {1'b0, v_range};
          end
        else
          begin
            v_vector_14 = v_vector_b;
          end
      end
  end

assign v_vector = v_vector_14[12:0];  

endmodule


