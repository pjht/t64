module mmu (input [63:0] addrin,din,pl6pdata,
            input reset,memcycle,clk,pl6pwr,pgen,stopwalk,
            output [63:0] addrout,
            output [1:0] width,
            output pgstrctwalk,pgft);
  
  logic [63:0] fetchedentry;
  wire [63:0] hitentry,walkaddr;
  logic [12:0] tlbwraddr=0;
  logic tlbwr,hit;
  
  
  tlb trlb({12'b0,addrin[63:12]},{12'b0,addrin[63:12]},fetchedentry,tlbwraddr,tlbwr,reset,hit,hitentry);
  pgfetcher fetcher(din,pl6pdata,addrin[63:12],memcycle,hit,reset,clk,pl6pwr,pgen,stopwalk,walkaddr,fetchedentry,tlbwr,pgstrctwalk,pgft);
  assign addrout=(pgstrctwalk) ? walkaddr : {hitentry[63:12],addrin[11:0]};
  assign width=2'h3;
  
  always @ (posedge tlbwr or reset) begin
    if (reset)
      tlbwraddr<=0;
    if (tlbwr & pgstrctwalk)
      tlbwraddr<=tlbwraddr+1;
  end
  
  
endmodule
