// ----------------------------------------------
// File: b_rres.v
// Module: b_rres
// Function:BusI/F(R) bus response controller
// ----------------------------------------------

module b_rres(
  clkdec
  ,rstdec_x
  ,vrh_line_type
  ,ph_vh_1_r_enable
  ,ph_vh_1_r_data
  ,vrh_line_enable
  ,vrh_que_full_r
  ,vrh_read_data_rd
);

input           clkdec;    
input           rstdec_x;  
input   [3:0]   vrh_line_type;    // sub module line type information
input           ph_vh_1_r_enable; //
input   [31:0]  ph_vh_1_r_data;   // SHwy response data
input           vrh_line_enable;  // sub module line enable information

output          vrh_que_full_r;   // sub module que full information
output  [63:0]  vrh_read_data_rd;  

reg     [3:0]   vrh_line_type_r;  // vrh_line_type 1 F/F
reg             vrh_line_enable_r;// vrh_line_enable 1 F/F 
reg     [3:0]   vrh_que0_r;       // line type que0
reg     [3:0]   vrh_que1_r;       // line type que1
reg     [3:0]   vrh_que2_r;       // line type que2
reg     [3:0]   vrh_que3_r;       // line type que3
reg     [3:0]   vrh_que4_r;       // line type que4
reg     [3:0]   vrh_que5_r;       // line type que5
reg     [3:0]   vrh_que6_r;       // line type que6
reg     [3:0]   vrh_que7_r;       // line type que7
reg             vrh_que_full_r;   // que full(7,8) signal
reg     [2:0]   vrh_que_cnt_write_r; // counter for write que 
reg     [2:0]   vrh_que_cnt_read_r;  // counter for read que
reg     [63:0]  vrh_rdata1_r;    
reg     [63:0]  vrh_rdata2_r;    
reg     [63:0]  vrh_read_data_r;  
reg             vrh_vh_1_r_enb_r; // 
reg     [63:0]  vrh_read_data_rd;
reg     [31:0]  ph_vh_1_r_data_r; // response data
reg             vrh_que_flag0_r;  // flag0 for que0
reg             vrh_que_flag1_r;  // flag1 for que1
reg             vrh_que_flag2_r;  // flag2 for que2
reg             vrh_que_flag3_r;  // flag3 for que3
reg             vrh_que_flag4_r;  // flag4 for que4
reg             vrh_que_flag5_r;  // flag5 for que5
reg             vrh_que_flag6_r;  // flag6 for que6
reg             vrh_que_flag7_r;  // flag7 for que7
reg     [2:0]   vrh_line_type_out_1_r;  // line type que0-8 out
reg     [2:0]   vrh_line_type_out_2_r;  // vrh_line_type_out_1_r 1F/F
reg             vrh_chan_byte1_r;       
reg             vrh_chan_byte2_r;  
reg             vrh_chan_byte3_r;  
reg             p_enable;
reg     [1:0]   bitphase; 

wire  [3:0]  vrh_que0_r_sig;    // signal for que0 
wire  [3:0]  vrh_que1_r_sig;    // signal for que1
wire  [3:0]  vrh_que2_r_sig;    // signal for que2
wire  [3:0]  vrh_que3_r_sig;    // signal for que3
wire  [3:0]  vrh_que4_r_sig;    // signal for que4
wire  [3:0]  vrh_que5_r_sig;    // signal for que5
wire  [3:0]  vrh_que6_r_sig;    // signal for que6
wire  [3:0]  vrh_que7_r_sig;    // signal for que7
wire  [3:0]  vrh_line_type_out; // signal for vrh_line_type_out_1_r
wire  [2:0]  vrh_que_sum0;      // que sum total 0123
wire  [2:0]  vrh_que_sum1;      // que sum total 4567
wire  [3:0]  vrh_que_sum;       // que sum total 01234567

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
              p_enable <= 1'b0;
  else
              p_enable <= ~p_enable;
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_line_type_r <= 4'd0;
        else
                vrh_line_type_r <= vrh_line_type + vrh_line_type_r - 1;
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_line_enable_r <= 1'b0;
        else
                vrh_line_enable_r <= vrh_line_enable;
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_vh_1_r_enb_r <= 1'b0;
        else
                vrh_vh_1_r_enb_r <= ph_vh_1_r_enable;
end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                ph_vh_1_r_data_r <= 31'd0;
        else
                ph_vh_1_r_data_r <= ph_vh_1_r_data;
 end

//write side select que8 (0 1 2 3 4 5 6 7)  
always @(posedge clkdec or negedge rstdec_x)
 begin
  if (!rstdec_x)
     vrh_que0_r <= 4'b0000;
  else
    vrh_que0_r <= vrh_que0_r_sig;
 end

assign vrh_que0_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b000))? vrh_line_type_r: vrh_que0_r - 1; 

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que1_r <= 4'b0000;
        else
                vrh_que1_r <= vrh_que1_r_sig;
 end

assign vrh_que1_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b001))? vrh_line_type_r: vrh_que1_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que2_r <= 4'b0000;
        else
                vrh_que2_r <= vrh_que2_r_sig;
 end

assign vrh_que2_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b010))? vrh_line_type_r: vrh_que2_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que3_r <= 4'b0000;
        else
                vrh_que3_r <= vrh_que3_r_sig;
 end

assign vrh_que3_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b011))? vrh_line_type_r: vrh_que3_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que4_r <= 4'b0000;
        else
                vrh_que4_r <= vrh_que4_r_sig;
 end

assign vrh_que4_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b100))? vrh_line_type_r: vrh_que4_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que5_r <= 4'b0000;
        else
                vrh_que5_r <= vrh_que5_r_sig;
 end

assign vrh_que5_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b101))? vrh_line_type_r: vrh_que5_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que6_r <= 4'b0000;
        else
                vrh_que6_r <= vrh_que6_r_sig;
 end

assign vrh_que6_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b110))? vrh_line_type_r: vrh_que6_r - 1'b1;

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_que7_r <= 4'b0000;
        else
                vrh_que7_r <= vrh_que7_r_sig;
 end

assign vrh_que7_r_sig = ((vrh_line_enable_r)&&(vrh_que_cnt_write_r == 3'b111))? vrh_line_type_r: vrh_que7_r - 1'b1;

// write enable counter(2bit) for select que8 (0 1 2 3 4 5 6 7) 
always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que_cnt_write_r <= 3'b000;
        else if(vrh_line_enable_r==1'b1)
                vrh_que_cnt_write_r <= vrh_que_cnt_write_r + 1;
  else
                vrh_que_cnt_write_r <= vrh_que_cnt_write_r;
end

//read side select que8 (0 1 2 3 4 5 6 7)  
assign vrh_line_type_out = line_type_read (vrh_que_cnt_read_r,
                                           vrh_que0_r,vrh_que1_r,vrh_que2_r,vrh_que3_r,
                                           vrh_que4_r,vrh_que5_r,vrh_que6_r,vrh_que7_r) ;

function [3:0]  line_type_read;
input  [2:0]  vrh_que_cnt_read_r;
input  [3:0]  vrh_que0_r;
input  [3:0]  vrh_que1_r;
input  [3:0]  vrh_que2_r;
input  [3:0]  vrh_que3_r;
input   [3:0]   vrh_que4_r;
input   [3:0]   vrh_que5_r;
input   [3:0]   vrh_que6_r;
input   [3:0]   vrh_que7_r;


begin
 case (vrh_que_cnt_read_r)
  3'b000: line_type_read = vrh_que0_r;
  3'b001: line_type_read = vrh_que1_r;
  3'b010: line_type_read = vrh_que2_r;
  3'b011: line_type_read = vrh_que3_r;

        3'b100: line_type_read = vrh_que4_r;
        3'b101: line_type_read = vrh_que5_r;
        3'b110: line_type_read = vrh_que6_r;
        3'b111: line_type_read = vrh_que7_r;

 endcase
end

endfunction 

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
               vrh_chan_byte1_r  <= 1'b0;
        else
                vrh_chan_byte1_r <= vrh_line_type_out[3];
        end


always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
               vrh_chan_byte2_r  <= 1'b0;
        else
                vrh_chan_byte2_r <= vrh_chan_byte1_r;
        end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
               vrh_chan_byte3_r  <= 1'b0;
        else
                vrh_chan_byte3_r <= vrh_chan_byte2_r;
        end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que_cnt_read_r <= 3'b000;
        else if(vrh_vh_1_r_enb_r==1'b1)
                vrh_que_cnt_read_r <= vrh_que_cnt_read_r + vrh_chan_byte3_r;
end

always @(posedge clkdec or negedge rstdec_x)    
begin
        if (!rstdec_x)
                vrh_que_flag0_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b000)
                vrh_que_flag0_r <= 1'b1;
        else
                vrh_que_flag0_r <=vrh_que_flag0_r;
end

always @(posedge clkdec or negedge rstdec_x)    
begin
        if (!rstdec_x)
                vrh_que_flag1_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b001)
                vrh_que_flag1_r <= 1'b1;
        else
                vrh_que_flag1_r <=vrh_que_flag1_r;
end

always @(posedge clkdec or negedge rstdec_x)    
begin
        if (!rstdec_x)
                vrh_que_flag2_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b010)
                vrh_que_flag2_r <= 1'b1;
        else
                vrh_que_flag2_r <=vrh_que_flag2_r;
end

always @(posedge clkdec or negedge rstdec_x)    
begin
        if (!rstdec_x)
                vrh_que_flag3_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b011)
                vrh_que_flag3_r <= 1'b1;
        else
                vrh_que_flag3_r <=vrh_que_flag3_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que_flag4_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b100)
                vrh_que_flag4_r <= 1'b1;
        else
                vrh_que_flag4_r <=vrh_que_flag4_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que_flag5_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b101)
                vrh_que_flag5_r <= 1'b1;
        else
                vrh_que_flag5_r <=vrh_que_flag5_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
       if (!rstdec_x)
                vrh_que_flag6_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b110)
                vrh_que_flag6_r <= 1'b1;
        else
                vrh_que_flag6_r <=vrh_que_flag6_r;
end

always @(posedge clkdec or negedge rstdec_x)
begin
        if (!rstdec_x)
                vrh_que_flag7_r <= 1'b0;
        else if(vrh_que_cnt_write_r==3'b111)
                vrh_que_flag7_r <= 1'b1;
        else
                vrh_que_flag7_r <=vrh_que_flag7_r;
end


assign vrh_que_sum0 = vrh_que_flag0_r + vrh_que_flag1_r + vrh_que_flag2_r + vrh_que_flag3_r;
assign vrh_que_sum1 = vrh_que_flag4_r + vrh_que_flag5_r + vrh_que_flag6_r + vrh_que_flag7_r;

assign vrh_que_sum = vrh_que_sum0 + vrh_que_sum1;

// create response full 
always @(posedge clkdec or negedge rstdec_x)
begin
  if (!rstdec_x)
     vrh_que_full_r <=1'b0;
  else if ((vrh_que_sum[3:0]==4'b1000)||(vrh_que_sum[3:0]== 4'b0111)||(vrh_que_sum[3:0]== 4'b0110))
    vrh_que_full_r <= 1'b1;
        else
                vrh_que_full_r <= 1'b0;
end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                bitphase <= 2'b00;
        else 
                bitphase <= bitphase + 1'b1;
 end



//res_control
always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_rdata1_r <= 64'd0;
        else if(bitphase==2'b10)
                vrh_rdata1_r[63:32] <= ph_vh_1_r_data_r;
        else if(bitphase==2'b01 || bitphase==2'b11)
                vrh_rdata1_r[31:0] <= ph_vh_1_r_data_r;
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_rdata2_r <= 64'd0;
        else
                vrh_rdata2_r <= vrh_rdata1_r;
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_line_type_out_1_r <= 3'b000;
        else
                vrh_line_type_out_1_r <= vrh_line_type_out[2:0];
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
                vrh_line_type_out_2_r <= 3'b000;
        else
                vrh_line_type_out_2_r <= vrh_line_type_out_1_r;
 end

always @(posedge clkdec or negedge rstdec_x)
 begin
        if (!rstdec_x)
              vrh_read_data_r <= 64'd0;
  else begin
              vrh_read_data_r[63:48] <= vrh_rdata2_r[63:48] & {16{vrh_line_type_out_2_r[2]^vrh_line_type_out_2_r[1]}};
              vrh_read_data_r[47:32] <= vrh_rdata2_r[47:32] & {16{vrh_line_type_out_2_r[1]^vrh_line_type_out_2_r[0]}};
              vrh_read_data_r[31:16] <= vrh_rdata2_r[31:16] & {16{vrh_line_type_out_2_r[2]^vrh_line_type_out_2_r[1]}};
              vrh_read_data_r[15:0]  <= vrh_rdata2_r[15:0]  & {16{vrh_line_type_out_2_r[1]^vrh_line_type_out_2_r[0]}};
        end
 end

always @(posedge clkdec or negedge rstdec_x)
 begin 
        if (!rstdec_x)
              vrh_read_data_rd <= 64'd0;
  else if(p_enable)
              vrh_read_data_rd <= vrh_read_data_r;
 end

endmodule

