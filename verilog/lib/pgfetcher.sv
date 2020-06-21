module pgfetcher (input [63:0] din,pl6pdata,
                  input [51:0] pgnoin,
                  input memcycle,hit,reset,clk,pl6pwr,pgen,stopwalk,
                  output [63:0] walkaddr,
                  output logic [63:0] writeentry,
                  output tlbwr,
                  output logic pgstrctwalk,pgft);
  
    logic [63:0] pl6p=0;
    logic [63:0] fetchedentry=0;
    logic [8:0] pgoffset;
    logic [2:0] fetchphase;
    logic pgstrctwalk_ff;
    
    
    assign writeentry=din;
    assign pgstrctwalk=((~hit || pgstrctwalk_ff) && pgen && memcycle && !stopwalk);
    assign pgft=(din[0]==0 && pgstrctwalk);
    assign walkaddr={((fetchphase==0) ? pl6p[63:12] : fetchedentry[63:12]),pgoffset,3'b0};
    assign tlbwr=(fetchphase==6);
  
    always @ ( posedge clk or hit or reset or posedge stopwalk) begin
      if (hit || reset || stopwalk)
        pgstrctwalk_ff<=0;
      else if (memcycle && clk && pgen)
        pgstrctwalk_ff<=1;
    end
    
    always @ ( * ) begin
      case (fetchphase)
        0: pgoffset=pgnoin[51:45];
        1: pgoffset=pgnoin[44:36];
        2: pgoffset=pgnoin[35:27];
        3: pgoffset=pgnoin[26:18];
        4: pgoffset=pgnoin[17:9];
        5: pgoffset=pgnoin[8:0];
        default: pgoffset=0;
      endcase
    end
    
    always @ (posedge clk or reset or hit or pgstrctwalk_ff or posedge stopwalk) begin
      if (hit || reset || stopwalk) 
        fetchphase<=0;
      if(clk && pgstrctwalk_ff)
        fetchphase<=fetchphase+1;
      if(clk && pgstrctwalk_ff && ~tlbwr)
        fetchedentry<=din;
      if (clk && pl6pwr)
        pl6p<=pl6pdata;
    end

endmodule
