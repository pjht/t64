module tlb #(parameter length = 4096) (input [63:0] pageno,wrpageno,tableentry,
              input [12:0] wraddr,
              input write,
              input reset,
              output logic hit,
              output logic[63:0] data);
  
  logic[64:0] pgnos[length-1:0];
  logic[64:0] entries[length-1:0];
  integer i=0;
  
  always @ (posedge write or reset) begin
    if (reset) begin
      for (i=0;i<length;i=i+1)
        pgnos[i]=64'h0;
        entries[i]=64'h0;
    end
    else if (write) begin
      pgnos[wrpageno]=wrpageno;
      entries[wrpageno]=tableentry;
    end
  end
  always @ ( * ) begin
    data=0;
    hit=0;
    for (i=0;i<length;i=i+1)
      if ((pgnos[i]==pageno)&&entries[i][0]&&~hit) begin
        data=entries[i];
        hit=1;
      end
  end
endmodule
