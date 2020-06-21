module regfile_if_tb();
 
  logic[63:0] din,retaddr,imm,aluout,rdaout,rdbout;
  logic[1:0] width;
  logic reset,wr,retload,immload,aluload,setr;
  logic[3:0] wrsel,rdasel,rdbsel;
 
  regfile_if DUT (
    .din(din),
    .retaddr(retaddr),
    .imm(imm),
    .aluout(aluout),
    .rdaout(rdaout),
    .rdbout(rdbout),
    .width(width),
    .reset(reset),
    .wr(wr),
    .retload(retload),
    .immload(immload),
    .aluload(aluload),
    .setr(setr),
    .wrsel(wrsel),
    .rdasel(rdasel),
    .rdbsel(rdbsel)
  );
 
  initial begin
    $dumpfile("dumps/regfile_if.vcd");
    $dumpvars(0,regfile_if_tb);
  end
 
endmodule
