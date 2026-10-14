// ----------------------------------------------
// File: iq_both.v
// Module: iq_both
// Function:Booth Decoder (15x15 multiplier)
// ----------------------------------------------

module iq_both(
  b_x,
  b_y,
  b_p8,
  b_p7,
  b_p6,
  b_p5,
  b_p4,
  b_p3,
  b_p2,
  b_p1,
  b_p0,
  b_c8,
  b_c7,
  b_c6,
  b_c5,
  b_c4,
  b_c3,
  b_c2,
  b_c1,
  b_c0
);
  input  [16:0] b_x;  
  input  [16:0] b_y;  
  output [17:0] b_p8;
  output [17:0] b_p7;
  output [17:0] b_p6;
  output [17:0] b_p5;
  output [17:0] b_p4;
  output [17:0] b_p3;
  output [17:0] b_p2;
  output [17:0] b_p1;
  output [17:0] b_p0;
  output [1:0]  b_c8;
  output [1:0]  b_c7;
  output [1:0]  b_c6;
  output [1:0]  b_c5;
  output [1:0]  b_c4;
  output [1:0]  b_c3;
  output [1:0]  b_c2;
  output [1:0]  b_c1;
  output        b_c0;

  function [18:0] F_BOX2;
    input [16:0] x;
    input y;

    begin
      if (y) begin
        F_BOX2[17]=x[16];
        F_BOX2[16:0]=~x;
        F_BOX2[18]=1'b1;
      end
      else begin
        F_BOX2[17]=1'b1;
        F_BOX2[16:0]=17'h00000;
        F_BOX2[18]=1'b0;
      end
    end
  endfunction

  function [19:0] F_BOX1;
    input [16:0] x;
    input [2:0] y;

    begin
      case(y)
        3'b000,3'b111 :                 // 0
        begin
          F_BOX1[17]=1'b1;
          F_BOX1[16:0]=17'h00000;
          F_BOX1[19:18] = 2'b00;
        end
        3'b001,3'b010 :                 // X
        begin
          F_BOX1[17]=~x[16];
          F_BOX1[16:0]=x;
          F_BOX1[19:18] = 2'b00;
        end
        3'b011 :                        // 2X
        begin
          F_BOX1[17]=~x[16];
          F_BOX1[16:0]={x[15:0],1'b0};
          F_BOX1[19:18] = 2'b00;
        end
        3'b100 :                        // -2X
        begin
          F_BOX1[17]=x[16];
          F_BOX1[16:0]={~x[15:0],1'b0};
          F_BOX1[19:18] = 2'b10;
        end
        3'b101,3'b110 :                 // -X
        begin
          F_BOX1[17]=x[16];
          F_BOX1[16:0]=~x;
          F_BOX1[19:18] = 2'b01;
        end
      endcase
    end
  endfunction

  assign {b_c0,b_p0} = F_BOX2(b_x,b_y[0]);
  assign {b_c1,b_p1} = F_BOX1(b_x,b_y[2:0]);
  assign {b_c2,b_p2} = F_BOX1(b_x,b_y[4:2]);
  assign {b_c3,b_p3} = F_BOX1(b_x,b_y[6:4]);
  assign {b_c4,b_p4} = F_BOX1(b_x,b_y[8:6]);
  assign {b_c5,b_p5} = F_BOX1(b_x,b_y[10:8]);
  assign {b_c6,b_p6} = F_BOX1(b_x,b_y[12:10]);
  assign {b_c7,b_p7} = F_BOX1(b_x,b_y[14:12]);
  assign {b_c8,b_p8} = F_BOX1(b_x,b_y[16:14]);

endmodule

