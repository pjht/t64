class T64
rule
  start: {
          @code=[]
          @labels={}
          @ops=["NOT","AND","OR","ADD","SUB","MULL","MULH","MULUL","MULUH",
                "DIVL","DIVH","DIVUL","DIVUH","NEG","CMP","ADC","SBB"]
          @pos=0
          @backpatches={}
          @linestarts=[]
          @lineends=[]
         } program {return @code,@labels,@linestarts,@lineends}
  program: line NEWLINE program {} | line NEWLINE {} | NEWLINE {@linestarts.push @pos;@lineends.push @pos} program {} | NEWLINE {@linestarts.push @pos;@lineends.push @pos}
  line: IDENT COLON {@startpos=@pos} ins {
                                            @labels[val[0]]=@startpos
                                            defed_label(val[0])
                                            @linestarts.push @startpos
                                            @lineends.push @pos
                                         } 
      | IDENT COLON {
                      @labels[val[0]]=@pos
                      defed_label(val[0])
                      @linestarts.push @pos
                      @lineends.push @pos
                    } 
      | {@startpos=@pos} ins {
                              @linestarts.push @startpos
                              @lineends.push @pos
                             }
  ins: LDB REG COMMA LPAREN IDENT RPAREN {@code.push([0x0,0x10|val[1],0x0,*get_label(val[4])]);@pos+=0x10}
     | LDB REG COMMA NUM  {@code.push([0x0,val[1],0x0,*val[3][0,1]]);@pos+=0x10}
     | LDB REG COMMA REG LPAREN REG RPAREN  {@code.push([0x0,0x30|val[1],val[3]<<4|val[5],*val[3,1]]);@pos+=0x10}
     | LDB REG COMMA LPAREN REG RPAREN  {@code.push([0x0,0x20|val[1],val[4]<<4]);@pos+=0x10}
     | LDW REG COMMA NUM  {@code.push([0x1,val[1],0x0,*val[3][0,2]]);@pos+=0x10}
     | LD REG COMMA NUM {@code.push([0x03,val[1],0x0,*val[3]]);@pos+=0x10}
     | LD REG COMMA IDENT {@code.push([0x03,val[1],0x0,*get_label(val[3])]);@pos+=0x10}
     | LD REG COMMA LPAREN IDENT RPAREN {@code.push([0x03,0x10|val[1],0x0,*get_label(val[4])]);@pos+=0x10}
     | ARB REG COMMA REG COMMA REG COMMA AROP COMMA NUM {@code.push([0x8,0x70|val[1],(val[3]<<4)|val[5],@ops.index(val[7])|(val[9][0]<<7)]);@pos+=0x10}
     | ARIB REG COMMA REG COMMA NUM COMMA AROP COMMA NUM {@code.push([0x8,0x80|val[1],(val[3]<<4),@ops.index(val[7]),val[5][0]]);@pos+=0x10}
     | ARW REG COMMA REG COMMA REG COMMA AROP COMMA NUM {@code.push([0x9,0x70|val[1],(val[3]<<4)|val[5],@ops.index(val[7])|(val[9][0]<<7)]);@pos+=0x10}
     | ARI REG COMMA REG COMMA NUM COMMA AROP COMMA NUM {@code.push([0xb,0x80|val[1],(val[3]<<4),@ops.index(val[7])|((val[9][0])<<7),*val[5]]);@pos+=0x10}
     | AR REG COMMA REG COMMA REG COMMA AROP {@code.push([0xb,0x70|val[1],(val[3]<<4)|val[5],@ops.index(val[7])]);@pos+=0x10}
     | ST REG COMMA LPAREN REG RPAREN {@code.push([0x7,0x20,(val[4]<<4|val[1])]);@pos+=0x10}
     | ST REG COMMA NUM LPAREN IDENT RPAREN {@code.push([0x7,0x40,val[1],*get_label(val[5]),*val[3][0,4]]);@pos+=0x10}
     | STB REG COMMA LPAREN IDENT RPAREN {@code.push([0x4,0x10,val[1],*get_label(val[4])]);@pos+=0x10}
     | STB REG COMMA NUM LPAREN IDENT RPAREN {@code.push([0x4,0x90,val[1],*get_label(val[5]),*val[3][0,4]]);@pos+=0x10}
     | STB REG COMMA REG LPAREN REG RPAREN {@code.push([0x4,0x20,(val[5]<<4|val[1]),val[3]]);@pos+=0x10}
     | STB REG COMMA LPAREN REG RPAREN  {@code.push([0x4,0x20,(val[4]<<4)|val[1]]);@pos+=0x10}
     | JNC LPAREN IDENT RPAREN {@code.push([0x10,0x10,0x0,*get_label(val[2])]);@pos+=0x10}
     | JNZ LPAREN IDENT RPAREN {@code.push([0xe,0x10,0x0,*get_label(val[2])]);@pos+=0x10}
     | JMP LPAREN IDENT RPAREN {@code.push([0xc,0x10,0x0,*get_label(val[2])]);@pos+=0x10}
     | JMP LPAREN REG RPAREN {@code.push([0xc,0x20,val[2]<<4]);@pos+=0x10}
     | JMP NUM {@code.push([0xc,0x10,0x0,*val[1]]);@pos+=0x10}
     | JNZ NUM {@code.push([0xe,0x10,0x0,*val[1]]);@pos+=0x10}
     | JST REG COMMA LPAREN IDENT RPAREN {@code.push([0x11,0x10|val[1],0x0,*get_label(val[4])]);@pos+=0x10}
     | HLT {@code.push([0xFF]);@pos+=0x10}
     | DB NUM {@code.push([*val[1][0,1]]);@pos+=1}
     | DQW NUM {@code.push([*val[1]]);@pos+=8}
     | ORG NUM {@pos=val[1].pack("C*").unpack("Q<")}
      
end

---- inner
def parse(input)
  scan_str(input)
end
def get_label(label)
  if @labels[label]
    return make_bytes(@labels[label])
  else
    return [label]+[0]*7
  end
end
def make_bytes(val)
  bytes=[]
  8.times do |i|
    mask=0xFF << i*8
    byte=(val&mask) >> i*8
    bytes.push byte
  end
  return bytes
end
def defed_label(label)
  newcode=[]
  for line in @code
    for index in line.each_index.select {|index| line[index]==label}
      line[index,8]=make_bytes(@labels[label])
    end
    newcode.push line
  end
  @code=newcode
end
