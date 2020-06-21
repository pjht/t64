module mmu_tb ();
  
reg [63:0] addrin,din,pl6pdata;
reg reset,memcycle,clk,pl6pwr;
wire [63:0] addrout;
wire [1:0] width;
wire pgstrctwalk,pgft;

mmu DUT(
  .addrin(addrin),
  .din(din),
  .pl6pdata(pl6pdata),
  .reset(reset),
  .memcycle(memcycle),
  .clk(clk),
  .pl6pwr(pl6pwr),
  .addrout(addrout),
  .width(width),
  .pgstrctwalk(pgstrctwalk),
  .pgft(pgft)
);

initial begin
  $dumpfile("dumps/mmu.vcd");
  $dumpvars(0,mmu_tb);
  addrin=64'h0;
  din=64'h0;
  pl6pdata=64'h0;
  reset=1'b0;
  memcycle=1'b0;
  clk=1'b0;
  pl6pwr=1'b0;
  #1;
  reset=1'b1;
  #1;
  reset=1'b0;
  pl6pdata=64'h1000;
  pl6pwr=1'b1;
  clk=1'b1;
  #1;
  clk=1'b0;
  pl6pwr=1'b0;
  #1;
  din=64'h2001;
  memcycle=1'b1;
  clk=1'b1;
  #1
  clk=1'b0;
  #1
  din=64'h3000;
  clk=1'b1;
  #1
  clk=1'b0;
  #1
  din=64'h4001;
  clk=1'b1;
  #1;
  clk=1'b0;
  #1;
  din=64'h5001;
  clk=1'b1;
  #1;
  clk=1'b0;
  #1;
  din=64'h6001;
  clk=1'b1;
  #1;
  clk=1'b0;
  #1;
  din=64'ha001;
  clk=1'b1;
  #1;
  clk=1'b0;
  #1;
end

endmodule
