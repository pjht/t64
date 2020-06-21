module pc (input clk,reset,jump,
           input[63:0] jumpaddr,
           output wire[63:0] retaddr,pc);

logic[63:0] pcreg=0;

assign pc=pcreg;
assign retaddr=pc+16;

always @ (posedge clk or reset or jump) begin
  if(reset)
    pcreg<=0;
  else if(jump)
    pcreg<=jumpaddr;
  else if(clk)
    pcreg<=pc+16;
end
  
endmodule 
