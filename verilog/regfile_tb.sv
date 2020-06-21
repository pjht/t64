module regfile_tb();
 
  logic [63:0] din,rdaout,rdbout;
  logic [3:0] wrsel,rdasel,rdbsel;
  logic [1:0] width;
  logic reset,wr;
 
  regfile DUT (
    .din(din),
    .rdaout(rdaout),
    .rdbout(rdbout),
    .wrsel(wrsel),
    .rdasel(rdasel),
    .rdbsel(rdbsel),
    .reset(reset),
    .wr(wr),
    .width(width)
  );
 
  initial begin
    $dumpfile("dumps/regfile.vcd");
    $dumpvars(0,regfile_tb);
    width=2'h0;
    din=64'h0;
    reset=1'b0;
    wr=1'b0;
    wrsel=4'h0;
    rdasel=4'h0;
    rdbsel=4'h0;
    #1
    width=2'h0;
    din=64'h0;
    reset=1'b1;
    wr=1'b0;
    wrsel=4'h0;
    rdasel=4'h0;
    rdbsel=4'h0;
    #1
    reset=1'b0;
    #1
    din=64'hFFFFFFFFFFFFFFFF;
    wr=1'b1;
    #1
    wr=1'b0;
    #1
    reset=1'b1;
    #1
    reset=1'b0;
    #1
    $finish;
  end
 
endmodule
