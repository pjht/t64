module regfile (input[63:0] din,
                  input[1:0] width,
                  input reset,wr,
                  input[3:0] wrsel,rdasel,rdbsel,
                  output wire[63:0] rdaout,rdbout);
  reg[63:0] regs[16];
  always @ (wr or reset) begin
    if(reset) begin
      integer i;
      for(i=0; i<16; i=i+1) begin
        regs[i]<=0;
      end
    end;
    if(wr) begin
      if(width==0) begin
        regs[wrsel]<=din&64'hFF;
      end
      if(width==1) begin
        regs[wrsel]<=din&64'hFFFF;
      end
      if(width==2) begin
        regs[wrsel]<=din&64'hFFFFFFFF;
      end
      if(width==3) begin
        regs[wrsel]<=din;
      end
    end
  end
  assign rdaout=regs[rdasel];
  assign rdbout=regs[rdbsel];
endmodule
