// ----------------------------------------------
// File: busiftop.v
// Module: busiftop
// Function:BusI/F top
// ----------------------------------------------
// History:
// Version Date          Author    Description
// v1.0    14.June.2004   hdlab     Original
// ----------------------------------------------
// Modification History:
// $Log: busiftop.v,v $
// Revision 1.15  2004/09/21 07:46:08  sabato
// *** empty log message ***
//
// Revision 1.14  2004/09/16 02:21:28  sabato
// modify rtq
//
// Revision 1.13  2004/09/14 11:34:41  sabato
// modify for scan
//
// Revision 1.12  2004/09/10 07:52:18  sabato
// modify
//
// Revision 1.11  2004/09/10 05:47:56  sabato
// modify
//
// Revision 1.10  2004/09/10 03:47:08  sabato
// modify
//
// Revision 1.9  2004/09/08 11:20:41  sabato
// modify
//
// Revision 1.8  2004/09/03 08:44:54  sabato
// modify
//
// Revision 1.7  2004/09/03 08:38:04  sabato
// modify vmem_wen
//
// Revision 1.6  2004/08/03 08:05:26  sabato
// modify vmem_wen retiming
//
// Revision 1.5  2004/07/23 07:05:27  sabato
// modify vmem add width
//
// Revision 1.4  2004/06/18 04:22:25  sabato
// modify ph_vh_1_r_enable
//
// Revision 1.3  2004/06/18 04:02:38  sabato
// modifi case : all signal
//
// Revision 1.2  2004/06/18 03:45:35  sabato
// modify reset:ph_vh_2_gnt
//
// Revision 1.1  2004/06/14 09:43:23  sabato
// initial
//
//

module busiftop(
                clkdec,   
                rstdec_x, 
                ph_vh_1_gnt,
                ph_vh_1_r_data,
                ph_vh_1_r_enable,
                vh_1_ph_req,
                vh_1_ph_add,
                ph_vh_1_r_en,
                ph_vh_2_gnt,       
                vh_2_ph_req,           
                vh_2_ph_add,           
                vh_2_ph_data,          
                vmem_we,           
                vmem_we_n,           
                vmem_wen,           
                vmem_ren,           
                vmem_add,           
                vmem_data_out,
                vmem_data_in,
                vmem_ch,
                v_bs_da 
                );

input           clkdec;
input           rstdec_x;
output          ph_vh_1_gnt;            // read ack
output [31:0]   ph_vh_1_r_data;         // read data
output          ph_vh_1_r_enable;       // read enable
input           vh_1_ph_req;            // read request
input  [31:0]   vh_1_ph_add;            // read address
output          ph_vh_1_r_en;
output          ph_vh_2_gnt;            // write ack
input           vh_2_ph_req;            // write request
input  [31:0]   vh_2_ph_add;            // write address
input  [31:0]   vh_2_ph_data;           // write data
output [3:0]    vmem_we;                // mem bus write enable            
output [3:0]    vmem_we_n;              // mem bus write enable            
output          vmem_wen;               // mem bus write enable            
output          vmem_ren;               // mem bus read enable          
output [25:0]   vmem_add;               // mem bus address           
output [31:0]   vmem_data_out;          // mem bus data 
input  [31:0]   vmem_data_in;           // mem bus data 
input           vmem_ch;
input  [31:0]   v_bs_da;

reg [1:0]   status_b ;
reg [1:0]   status_b_current ;
reg         ph_vh_1_gnt;
reg         ph_vh_2_gnt;
reg         vmem_wen_r;
reg         ph_vh_1_r_en;
reg         ph_vh_1_r_en_r;
reg         ph_vh_1_r_enable;
reg         b_vmem_wen;             // mem bus write enable            
reg [3:0]   vmem_we; 
wire        b_vmem_ren,b_vmem_we;   // mem bus read enable          
wire [25:0] b_vmem_add;             // mem bus address           
wire [31:0] b_vmem_data_out;        // mem bus data 
wire        vmem_ren;               // mem bus read enable          
reg [25:0]  vmem_add;               // mem bus address           
reg [31:0]  vmem_data_out;          // mem bus data 
reg         vmem_ren_g;             // mem bus read enable          
reg         vmem_ch_r;
wire        v_bs_da_or,v_bs_da_or_n;

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x) begin
     vmem_wen_r <= 1'b1;
     vmem_we  <= 4'b0000;
   end else if(!vmem_ch) begin
     vmem_wen_r <= b_vmem_wen;
     vmem_we[0] <= b_vmem_we;
     vmem_we[1] <= b_vmem_we;
     vmem_we[2] <= b_vmem_we;
     vmem_we[3] <= b_vmem_we;
   end else begin
     vmem_wen_r <= v_bs_da_or_n;
     vmem_we[0] <= v_bs_da_or;
     vmem_we[1] <= v_bs_da_or;
     vmem_we[2] <= v_bs_da_or;
     vmem_we[3] <= v_bs_da_or;
   end
end

assign v_bs_da_or_n = ~v_bs_da_or;
assign v_bs_da_or = |(v_bs_da);
assign b_vmem_we = ~b_vmem_wen;
 
always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x) vmem_ch_r <= 1'b0;
   else
     vmem_ch_r <= vmem_ch;
end

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x) vmem_ren_g <= 1'b1;
   else if(~vmem_ch_r)
     vmem_ren_g <= b_vmem_ren;
   else 
     vmem_ren_g <= 
                    ~(v_bs_da[30] | v_bs_da[28] |v_bs_da[21] | v_bs_da[5]| v_bs_da[3]);
end

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x) vmem_add <= 26'h0000000;
   else if(~vmem_ch_r)
      vmem_add <= b_vmem_add;
   else 
      vmem_add <= 
            {v_bs_da[7:0],v_bs_da[12:8],v_bs_da[18:12],v_bs_da[25:19]};
end

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x) vmem_data_out <= 26'h0000000;
   else if(~vmem_ch_r)
     vmem_data_out <= b_vmem_data_out;
   else 
     vmem_data_out <= {v_bs_da[12:0],v_bs_da[25:13]};
end

assign  b_vmem_add = (status_b==2'b11)? vh_2_ph_add[25:0]+vh_2_ph_add[31:26]:vh_1_ph_add[25:0]+vh_1_ph_add[31:26];
assign  b_vmem_ren = ph_vh_1_r_enable;
assign  b_vmem_data_out = vh_2_ph_data;
assign  ph_vh_1_r_data = vmem_data_in;
assign  vmem_wen = vmem_wen_r;
assign  vmem_we_n[0] = ~vmem_we[0];
assign  vmem_we_n[1] = ~vmem_we[1];
assign  vmem_we_n[2] = ~vmem_we[2];
assign  vmem_we_n[3] = ~vmem_we[3];
assign  vmem_ren = ~vmem_wen_r | vmem_ren_g; 

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x)
     ph_vh_1_r_enable <= 1'b0;
   else
     case(status_b_current)
       2'b00 : ph_vh_1_r_enable <= 1'b1; 
       2'b01 : if(vh_2_ph_req)
                 ph_vh_1_r_enable <= 1'b1; 
               else 
                 ph_vh_1_r_enable <= 1'b0; 
       2'b10 : ph_vh_1_r_enable <= 1'b0; 
       2'b11 : ph_vh_1_r_enable <= 1'b1; 
     endcase
end

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x)
     b_vmem_wen    <= 1'b1;
   else
     case(status_b_current)
       2'b00 : b_vmem_wen    <= 1'b1;    
       2'b01 : b_vmem_wen    <= 1'b1;    
       2'b10 : b_vmem_wen    <= 1'b0;    
       2'b11 : b_vmem_wen    <= 1'b1;    
     endcase

end

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x)
     ph_vh_1_gnt <= 1'b0;
   else
     case(status_b_current)
       2'b00 : if(vh_1_ph_req)
                 ph_vh_1_gnt <= 1'b1;   
               else if(vh_2_ph_req)
                 ph_vh_1_gnt <= 1'b0;   
       2'b01 : ph_vh_1_gnt <= 1'b0;    
       2'b10 : ph_vh_1_gnt <= 1'b0;    
       2'b11 : if(vh_1_ph_req)
                 ph_vh_1_gnt <= 1'b1;   
               else 
                 ph_vh_1_gnt <= 1'b0;   
     endcase

end

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x)
     ph_vh_2_gnt <= 1'b0;
   else
     case(status_b_current)
       2'b00 : if(vh_1_ph_req)
                 ph_vh_2_gnt <= 1'b0;   
               else if(vh_2_ph_req)
                 ph_vh_2_gnt <= 1'b1;   
       2'b01 : if(vh_2_ph_req)
                 ph_vh_2_gnt <= 1'b1;   
               else
                 ph_vh_2_gnt <= 1'b0;   
       2'b10 : ph_vh_2_gnt <= 1'b1;   
       2'b11 : ph_vh_2_gnt <= 1'b0;   
     endcase

end


always@(status_b_current or vh_1_ph_req or vh_2_ph_req)begin
     case(status_b_current)
       2'b00 : if(vh_1_ph_req)
                 status_b    = 2'b01;        //state=read
               else if(vh_2_ph_req)
                 status_b    = 2'b10;        //state=write
               else
                 status_b    = 2'b00;  
       2'b01 : if(vh_2_ph_req)
                 status_b    = 2'b10;    //state=write
               else 
                 status_b    = 2'b00;    //state=idle
       2'b10 : status_b    = 2'b11;        //state=write_2nd
       2'b11 : if(vh_1_ph_req)
                 status_b    = 2'b01;      //state=read
               else 
                 status_b    = 2'b00;      //state=idle
     endcase

end


always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x)
     status_b_current    <= 2'b00;
   else
     status_b_current    <= status_b;
end 

always@(posedge clkdec or negedge rstdec_x)begin
   if(!rstdec_x)begin
     ph_vh_1_r_en_r <= 1'b0;   
     ph_vh_1_r_en   <= 1'b0;
   end else begin
     ph_vh_1_r_en_r <= ph_vh_1_r_enable;   
     ph_vh_1_r_en   <= ph_vh_1_r_en_r;   
   end
end

endmodule
