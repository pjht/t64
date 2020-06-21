module t64_system ();
  logic [63:0] din,addr,dout;
  logic [1:0] width;
  logic clk,reset,write,intr,intack,unhandledexcept;
  integer i;
  
  ram RAM (
    .din(dout),
    .dout(din),
    .ain(addr),
    .width(width),
    .write(write),
    .clk(clk)
  );
  
  t64 CPU (
    .din(din),
    .clk(clk),
    .reset(reset),
    .intr(intr),
    .aouttrue(addr),
    .dout(dout),
    .widthtrue(width),
    .writetrue(write),
    .intack(intack),
    .unhandledexcept(unhandledexcept)
  );
  
  
  wire[127:0] insword;
  assign insword={CPU.opl8,CPU.opf8};
  wire[63:0] dbus;
  assign dbus=(write) ? dout : din;
  initial begin
    $dumpfile("dumps/t64.lxt");
    $dumpvars(10,RAM,CPU,t64_system,RAM.ram[22]);
    for (i=0;i<16;i=i+1) begin
      $dumpvars(0,CPU.rf.rf.regs[i]);
    end
    for (i=0;i<65536;i=i+1) begin
      RAM.ram[i]=0;
    end
    $readmemh("prog.hex",RAM.ram);
    RAM.ram[16'hA000>>3]=64'hB001;
    RAM.ram[16'hB000>>3]=64'hC001;
    RAM.ram[16'hC000>>3]=64'hD001;
    RAM.ram[16'hD000>>3]=64'hE001;
    RAM.ram[16'hE000>>3]=64'hF001;
    RAM.ram[16'hF000>>3]=64'h0000;
    RAM.ram[16'hF008>>3]=64'h0001;
    RAM.ram[16'hF078>>3]=64'hF001;
    // CPU.memmu.fetcher.pl6p=64'hA000;
    intr=1'b0; clk=1'b0; reset=1'b1; #1;
    reset=1'b0;
    // repeat(32) begin
    //   clk=1'b1; #1;
    //   clk=1'b0; #1;
    //   if(RAM.ram[CPU.pc>>3]==64'hFF)
    //     $finish;
    //   end
    // end
    // intr=1'b1;
    forever begin
      clk=1'b1; #1;
      clk=1'b0; #1;
      if((CPU.phase==0 && din==64'hFF) || unhandledexcept) begin
        $finish;
      end
      if(intack) begin
        intr=1'b0;
      end
    end
  end
endmodule
