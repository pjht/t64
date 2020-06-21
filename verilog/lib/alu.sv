module alun #(parameter width = 8)
            (input[7:0] op,
            input[63:0] ain,bin,
            input cin,
            output logic[63:0] rout,
            output logic zero,carry,setcarry,setr);
            
  logic[width-1:0] a,b,r;
  logic[width:0] rwc;
  logic [127:0] r128;
  logic signed [width-1:0] asigned,bsigned;
  
  always @(*) begin
    a=ain[width-1:0];
    b=(op[7]) ? 0 : bin[width-1:0];
    carry=0;
    setcarry=0;
    setr=1;
    case(op[6:0])
      0: r=~a;
      1: r=a&b;
      2: r=a|b;
      3: begin
        rwc=a+b;
        r=rwc[width-1:0];
        carry=rwc[width:width];
        setcarry=1;
      end
      4: begin
        rwc=a-b;
        r=rwc[width-1:0];
        carry=rwc[width:width];
        setcarry=1;
      end
      5: begin
        asigned=a;
        bsigned=b;
        r=asigned*bsigned;
      end
      6: begin
        asigned=a;
        bsigned=b;
        r128=asigned*bsigned;
        r=r128[127:64];
      end
      7: r=a*b;
      8: begin
        r128=a*b;
        r=r128[127:64];
      end
      9: begin
        asigned=a;
        bsigned=b;
        r=asigned/bsigned;
      end
      10: begin
        asigned=a;
        bsigned=b;
        r128=asigned/bsigned;
        r=r128[127:64];
      end
      11: r=a/b;
      12: begin
          r128=a/b;
          r=r128[127:64];
        end
      13: begin
        asigned=a;
        r=~a;
      end
      14: begin
        rwc=a+b+cin;
        r=rwc[width-1:0];
        carry=rwc[width:width];
        setcarry=1;
      end
      // 15 is SBB
      16: begin
        rwc=a-b;
        carry=rwc[width:width];
        setcarry=1;
        setr=0;
      end
      default: r=0;
    endcase
    zero=(r==0);
    rout=r;
  end
endmodule

module alu(input[7:0] op,
           input[63:0] a,b,
           input cin,
           input[1:0] width,
           output logic[63:0] r,
           output logic zero,carry,setcarry,setr);
  wire[63:0] rs[4];
  wire zeros[4],carrys[4],setcarrys[4],setrs[4];
  alun #(8)  alu8(op,a,b,cin,rs[0],zeros[0],carrys[0],setcarrys[0],setrs[0]);
  alun #(16) alu16(op,a,b,cin,rs[1],zeros[1],carrys[1],setcarrys[1],setrs[1]);
  alun #(32) alu32(op,a,b,cin,rs[2],zeros[2],carrys[2],setcarrys[2],setrs[2]);
  alun #(64) alu64(op,a,b,cin,rs[3],zeros[3],carrys[3],setcarrys[3],setrs[3]);
  always @(*) begin
    r=rs[width];
    zero=zeros[width];
    carry=carrys[width];
    setcarry=setcarrys[width];
    setr=setrs[width];
  end
endmodule
