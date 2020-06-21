module control (input[63:0] opf8,opl8,
                input exec,carry,zero,
                output logic[63:0] imm,
                output wire[7:0] aluop,
                output wire[3:0] wrsel,rdasel,rdbsel,
                output reg[1:0] width,
                output wire retload,
                output reg regwr,memwr,aluload,jump,immload,memaddr,pointer,specialwr,iret);
wire[7:0] opcode;
wire[3:0] addrmode;
reg[1:0] opwidth;
reg regwrop,memwrop,jumpop,specialwrop;
assign opcode=opf8[7:0];
assign addrmode=opf8[15:12];
assign wrsel=opf8[11:8];
assign rdasel=opf8[23:20];
assign rdbsel=opf8[19:16];
assign aluop=opf8[31:24];
assign regwr=regwrop&exec;
assign memwr=memwrop&exec;
assign jump=jumpop&exec;
assign specialwr=(opcode==18)&exec;
assign iret=(opcode==19)&exec;
assign retload=(opcode==8'h11);
always @ ( * ) begin
  case (opcode)
    0: opwidth=0;
    1: opwidth=1;
    2: opwidth=2;
    3: opwidth=3;
    4: opwidth=0;
    5: opwidth=1;
    6: opwidth=2;
    7: opwidth=3;
    8: opwidth=0;
    9: opwidth=1;
    10: opwidth=2;
    11: opwidth=3;
    default: opwidth=0;
  endcase
  if (exec)
    width=opwidth;
  else
    width=3;
  case (opcode)
    0: regwrop=1;
    1: regwrop=1;
    2: regwrop=1;
    3: regwrop=1;
    8: regwrop=1;
    9: regwrop=1;
    10: regwrop=1;
    11: regwrop=1;
    17: regwrop=1;
    default: regwrop=0;
  endcase
  immload=0;
  memaddr=0;
  pointer=0;
  case (addrmode)
    0: immload=1;
    1: memaddr=1;
    2: pointer=1;
    8: immload=1;
    default: ;
  endcase
  if(addrmode==8) begin
    imm[31:0]=opf8[63:32];
    imm[63:32]=opl8[31:0];
  end
  else begin
    imm[39:0]=opf8[63:24];
    imm[63:40]=opl8[31:0];
  end
  case (opcode)
    4: memwrop=1;
    5: memwrop=1;
    6: memwrop=1;
    7: memwrop=1;
    default: memwrop=0;
  endcase
  case (opcode)
    8: aluload=1;
    9: aluload=1;
    10: aluload=1;
    11: aluload=1;
    default: aluload=0;
  endcase
  case (opcode)
    12: jumpop=1;
    13: jumpop=1&zero;
    14: jumpop=1&~zero;
    15: jumpop=1&carry;
    16: jumpop=1&~carry;
    17: jumpop=1;
    default: jumpop=0;
  endcase
  
end
  
endmodule // control
