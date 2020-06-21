module alu_if (input[63:0] rdaout,rdbout,imm,
               input[7:0] aluop,
               input[1:0] width,
               input clk,reset,immload,aluload,
               output wire[63:0] aluout,
               output wire zero,carry,setr
               );
  logic carryff;
  logic zeroff;
  wire carryffin;
  wire zeroffin;
  wire setcarry;
  wire[63:0] bin;
  assign bin=(immload) ? imm : rdaout;
  alu arlu(aluop,rdaout,bin,carryff,width,aluout,zeroffin,carryffin,setcarry,setr);
  assign carry=carryff;
  assign zero=zeroff;
  always @ (posedge clk or reset) begin
    if(reset) begin
      carryff<=0;
      zeroff<=0;
    end
    else if(clk) begin
      if(setcarry)
        carryff<=carryffin;
      if(aluload)
        zeroff<=zeroffin;
    end
  end
 endmodule
