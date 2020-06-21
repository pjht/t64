module ram (input[63:0] din,ain,
            input[1:0] width,
            input clk,write,
            output wire[63:0] dout);
            
  reg[63:0] ram[65536:0];
  reg[63:0] wrdata;
  reg[63:0] rddata;
  wire[63:0] ramval;
  assign ramval=ram[ain>>3];
  assign dout=(write&&clk) ? din : rddata;
  always @ ( * ) begin
    case(width)
    0: case(ain[2:0])
        0: wrdata={ramval[63:8],din[7:0]};
        1: wrdata={ramval[63:16],din[7:0],ramval[7:0]};
        2: wrdata={ramval[63:24],din[7:0],ramval[15:0]};
        3: wrdata={ramval[63:32],din[7:0],ramval[23:0]};
        4: wrdata={ramval[63:40],din[7:0],ramval[31:0]};
        5: wrdata={ramval[63:48],din[7:0],ramval[39:0]};
        6: wrdata={ramval[63:56],din[7:0],ramval[47:0]};
        7: wrdata={din[7:0],ramval[55:0]};
        default: wrdata=0;
      endcase
    1: case(ain[2:1])
        0: wrdata={ramval[63:16],din[15:0]};
        1: wrdata={ramval[63:32],din[15:0],ramval[15:0]};
        2: wrdata={ramval[63:48],din[15:0],ramval[31:0]};
        3: wrdata={ramval[15:0],ramval[47:0]};
        default: wrdata=0;
      endcase
    2: case(ain[2])
        0: wrdata={ramval[63:32],din[31:0]};
        1: wrdata={din[31:0],ramval[31:0]};
        default: wrdata=0;
      endcase
    3: wrdata=din;
    default: wrdata=0;
    endcase
  end
  always @ (posedge clk or write) begin
    if(write)
      ram[ain>>3]<=wrdata; 
  end
  always @ ( * ) begin
    case(width)
    0: case(ain[2:0])
        0: rddata=ramval[7:0];
        1: rddata=ramval[15:8];
        2: rddata=ramval[23:16];
        3: rddata=ramval[31:24];
        4: rddata=ramval[39:32];
        5: rddata=ramval[47:40];
        6: rddata=ramval[55:48];
        7: rddata=ramval[63:56];
        default: rddata=0;
      endcase
    1: case(ain[2:1])
        0: rddata=ramval[15:0];
        1: rddata=ramval[31:16];
        2: rddata=ramval[47:32];
        3: rddata=ramval[63:48];
        default: rddata=0;
      endcase
    2: case(ain[2])
        0: rddata=ramval[31:0];
        1: rddata=ramval[63:32];
        default: rddata=0;
      endcase
    3: rddata=ramval;
    endcase
  end
endmodule // ram
