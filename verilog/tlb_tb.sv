module tlb_tb ();
  logic [63:0] pageno,wrpageno,tableentry,data;
  logic [12:0] wraddr;
  logic write,hit,reset;
  
  tlb DUT (
    .pageno(pageno),
    .wrpageno(wrpageno),
    .tableentry(tableentry),
    .wraddr(wraddr),
    .write(write),
    .reset(reset),
    .hit(hit),
    .data(data)
  );
  
  initial begin
    $dumpfile("dumps/tlb.lxt");
    $dumpvars(0,tlb_tb);
    pageno=64'h0;
    wrpageno=64'h0;
    tableentry=64'h0;
    wraddr=12'h0;
    write=1'b0;
    reset=1'b0;
    #1;
    reset=1'b1;
    #1
    reset=1'b0;
    write=1'b1;
    #1;
    write=1'b0;
    tableentry=64'h5001;
    #1;
    write=1'b1;
    #1;
    write=1'b0;
    #1;
    pageno=64'h1;
    #1;
    wrpageno=64'h1;
    wraddr=12'h1;
    tableentry=64'h6001;
    write=1'b1;
    #1;
    write=1'b0;
    #1;
  end
endmodule
