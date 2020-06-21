module t64 (input[63:0] din,
            input clk,reset,intr,
            output logic[63:0] aouttrue,
            output wire[63:0] dout,
            output wire[1:0] widthtrue,
            output wire writetrue,
            output reg intack,
            output reg unhandledexcept);
    wire[63:0] rdaout,rdbout,aluout,imm,retaddr,pc,aouttrans;
    wire[7:0] aluop;
    wire[3:0] wrsel,rdasel,rdbsel,inslen;
    wire[1:0] width,walkwidth;
    wire zero,carry,setr,regwr,retload,immload,aluload,jump,pointer,memaddr;
    wire exec,pgstrctwalk,pgft,memcycle,specialwr,pl6pwr,intjumpaddrwr,iret;
    wire intr_gated,exceptjumpaddrwr,write,except_jump,int_jump;
    assign exec=(phase==2)&&!unhandledexcept&&!pendingexcept;
    assign dout=rdbout;
    assign writetrue=write&&!pgstrctwalk;
    assign aouttrue=(pgen) ? aouttrans : aout;
    assign widthtrue=(pgen&&pgstrctwalk) ? walkwidth : width;
    assign memcycle=phase==0||phase==1||pointer||memaddr;
    assign pl6pwr=(imm==0&specialwr);
    assign intjumpaddrwr=(imm==1&specialwr);
    assign exceptjumpaddrwr=(imm==2&specialwr);
    assign intr_gated=intr&inten&!unhandledexcept;
    reg[63:0] opf8,opl8,aout,intjumpaddr,exceptjumpaddr,exceptno,intretaddr;
    reg[63:0] exceptretaddr,jumpaddr;
    reg pgen=0;
    reg inten=0;
    reg excepten=0;
    reg oldinten=0;
    reg oldhandleint=0;
    reg handleint=0;
    reg handleexcept=0;
    reg stopwalk=0;
    reg pendingexcept=0;
    assign except_jump=excepten && pendingexcept && phase==0;
    assign int_jump=intr_gated && inten && phase==0;
    control cntrl(opf8,opl8,exec,carry,zero,imm,aluop,wrsel,rdasel,rdbsel,width,retload,regwr,write,aluload,jump,immload,memaddr,pointer,specialwr,iret);
    regfile_if rf(din,retaddr,imm,aluout,width,reset,regwr&&clk,retload,immload,aluload,setr,wrsel,rdasel,rdbsel,rdaout,rdbout);
    alu_if alu(rdaout,rdbout,imm,aluop,width,clk,reset,immload,aluload&&exec,aluout,zero,carry,setr);              
    pc pgmc(clk&&exec&&!pgstrctwalk,reset,jump||iret||int_jump||except_jump,jumpaddr,retaddr,pc);
    mmu memmu(aout,din,rdaout,reset,memcycle,clk,pl6pwr,pgen,stopwalk,aouttrans,walkwidth,pgstrctwalk,pgft);
    logic[1:0] phase;
    
    always @ ( * ) begin
      if (jump)
        jumpaddr=aout;
      else if (iret&&handleexcept)
        jumpaddr=exceptretaddr;
      else if (iret&&handleint)
        jumpaddr=intretaddr;
      else if (pendingexcept||handleexcept)
        jumpaddr=exceptjumpaddr;
      else if (intr_gated)
        jumpaddr=intjumpaddr;
      else
        jumpaddr=0;
    end
    
    always @ (posedge clk or reset or din) begin
      if(reset) begin
        phase<=0;
        opf8<=0;
        opl8<=0;
        pgen<=0;
        intjumpaddr<=0;
        intack<=0;
        inten<=0;
        excepten<=0;
        handleint<=0;
        handleexcept<=0;
        exceptjumpaddr<=0;
        exceptno<=0;
        oldinten<=0;
        oldhandleint<=0;
        unhandledexcept<=0;
        stopwalk<=0;
        pendingexcept<=0;
        intretaddr<=0;
        exceptretaddr<=0;
      end
      else if(clk) begin
        if(phase==0)
          opf8<=din;
        else if(phase==1)
          opl8<=din;
      end
    end
    
    always @ (negedge clk) begin
      if (!pgstrctwalk ||!pgen)
        if(phase!=2&&!intr_gated) begin
          phase<=phase+1;
          if (phase==1)
            intack<=0;
        end
        else begin
           phase<=0;
           if (pendingexcept)
            if (excepten && !handleexcept) begin
              handleexcept<=1;
              excepten<=0;
              oldinten<=inten;
              inten<=0;
              handleint<=0;
              oldhandleint<=handleint;
              pendingexcept<=0;
              stopwalk<=0;
            end
            else
              unhandledexcept<=1;
           else if (intr_gated) begin
            intretaddr<=retaddr;
            intack<=1;
            inten<=0;
            handleint<=1;
          end
        end
    end
    
    always @ ( posedge clk ) begin
      if(iret) begin
        $display("IRET");
        if(handleexcept) begin
        $display("HANDLE EXCEPTION. RETADDR:0x%x",exceptretaddr);
          handleexcept<=0;
          excepten<=1;
          inten<=oldinten;
          handleint<=oldhandleint;
          pgmc.pcreg<=exceptretaddr;
        end
      end
      else if (handleint) begin
        inten<=1;
        handleint<=0;
        pgmc.pcreg<=intretaddr;
      end  
    end
    
    always @ ( * ) begin
      if(phase==0)
        aout=pc;
      else if(phase==1)
        aout=pc+8;
      else if(pointer==1)
        aout=rdaout;
      else if(memaddr==1)
        aout=imm;
      else
        aout=0;
    end
    
    always @ ( posedge pl6pwr ) begin
      pgen<=rdaout[0];
    end
    
    always @ ( posedge intjumpaddrwr ) begin
      intjumpaddr<=rdaout&~64'h7;
      inten<=rdaout[0];
      excepten<=rdaout[0];
    end
    always @ ( posedge exceptjumpaddrwr ) begin
      exceptjumpaddr<=rdaout&~64'h7;
    end
    
    always @ ( posedge clk ) begin
      if (pgft==1) begin
        // #5;
        // $display("FAULT!! Before setting signals pgstrctwalk=%d pgft=%d stopwalk=%d aouttrue=0x%x aouttrans: 0x%x, aout: 0x%x, memmu.fetchedentry=0x%x din[0]=%d",pgstrctwalk,pgft,stopwalk,aouttrue,aouttrans,aout,memmu.fetchedentry,din[0]);
        pendingexcept<=1;
        exceptno<=0;
        stopwalk<=1;
        exceptretaddr<=pc;
        // $display("FAULT!! After setting signals pgstrctwalk=%d pgft=%d stopwalk=%d aouttrue=0x%x aouttrans: 0x%x, aout: 0x%x, memmu.fetchedentry=0x%x din[0]=%d",pgstrctwalk,pgft,stopwalk,aouttrue,aouttrans,aout,memmu.fetchedentry,din[0]);
        // #5;
        // $finish();
      end
    end
    
endmodule
