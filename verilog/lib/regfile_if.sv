module regfile_if (input[63:0] din,retaddr,imm,aluout,
                   input[1:0] width,
                   input reset,wr,retload,immload,aluload,setr,
                   input[3:0] wrsel,rdasel,rdbsel,
                   output wire[63:0] rdaout,rdbout);

logic[63:0] rf_din;
wire rf_wr;
                
regfile rf(rf_din,width,reset,rf_wr,wrsel,rdasel,rdbsel,rdaout,rdbout);

assign rf_wr=~(aluload&(~setr))&wr;

always @ ( din or retaddr or imm or aluout or retload or immload or aluload ) begin
  if(aluload)
    rf_din=aluout;
  else if(immload)
    rf_din=imm;
  else if(retload)
    rf_din=retaddr;
  else
    rf_din=din;
end
  
endmodule
