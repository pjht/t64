module pc_tb();
 
  logic clk,reset,jump;
  logic[63:0] jumpaddr,retaddr,pc;

  pc DUT (
    .clk(clk),
    .reset(reset),
    .jump(jump),
    .jumpaddr(jumpaddr),
    .retaddr(retaddr),
    .pc(pc)
  );
 
  initial begin
    $dumpfile("dumps/pc.vcd");
    $dumpvars(0,pc_tb);
    clk=1'b0;
    reset=1'b0;
    jump=1'b0;
    jumpaddr=64'h0;
    #1;
    reset=1'b1;
    #1;
    reset=1'b0;
    #1
    clk=1'b1;
    #1;
    clk=1'b0;
    #1
    clk=1'b1;
    #1;
    clk=1'b0;
    jumpaddr=64'h60;
    jump=1'b1;
    #1;
    clk=1'b1;
    #1;
    clk=1'b0;
    reset=1'b1;
    #1;
    reset=1'b0;
  end
 
endmodule
