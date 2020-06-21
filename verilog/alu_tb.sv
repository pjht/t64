module alu_tb();
 
  logic [63:0] a,b,r;
  logic [7:0] op;
  logic [1:0] width;
  logic cin,zero,carry,setcarry,setr;
 
  alu DUT (
    .a(a),
    .b(b),
    .op(op),
    .cin(cin),
    .width(width),
    .r(r),
    .zero(zero),
    .carry(carry),
    .setcarry(setcarry),
    .setr(setr)
  );
 
  initial begin
    $dumpfile("dumps/alu.vcd");
    $dumpvars(0,alu_tb);
    width=2'h0;
    cin=1'b0;
    a=64'hFF;
    b=64'h0;
    op=8'h0;
    #1;
    a=8'hA8;
    b=8'h22;
    op=8'h1;
    #1;
    $finish;
  end
 
endmodule
