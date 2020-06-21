class T64
macro
SPACE [\ ]+
rule
reta { [:REG,15] }
r\d+ { [:REG,text.to_i]}
0x[0-9a-f]+ { [:NUM, make_bytes(text.to_i(16))] }
\d+ { [:NUM, make_bytes(text.to_i)] }
\n { [:NEWLINE,"\n"]}
{SPACE} { }
\( { [:LPAREN,"("] }
\) { [:RPAREN,")"] }
, { [:COMMA,","] }
\#.+ {}
: { [:COLON,text]}
LDB { [:LDB,text] }
LDW { [:LDW,text] }
LDDW { [:LDDW,text] }
LD { [:LD,text] }
STB { [:STB,text] }
STW { [:STW,text] }
STDW { [:STDW,text] }
ST { [:ST,text] }
ARIB { [:ARIB,text] }
ARIW { [:ARIW,text] }
ARIDW { [:ARIDW,text] }
ARI { [:ARI,text] }
ARB { [:ARB,text] }
ARW { [:ARW,text] }
ARDW { [:ARDW,text] }
AR { [:AR,text] }
JMP { [:JMP,text] }
JC { [:JC,text] }
JNC { [:JNC,text] }
JZ { [:JZ,text] }
JNZ { [:JNZ,text] }
JST { [:JST,text] }
db { [:DB,text] }
dw { [:DW,text] }
ddw { [:DDW,text] }
dqw { [:DQW,text] }
org { [:ORG,text] }
NOT { [:AROP,text] }
AND { [:AROP,text] }
OR { [:AROP,text] }
ADD { [:AROP,text] }
SUB { [:AROP,text] }
MULL { [:AROP,text] }
MULH { [:AROP,text] }
MULUL { [:AROP,text] }
MULUH { [:AROP,text] }
DIVL { [:AROP,text] }
DIVH { [:AROP,text] }
DIVUL { [:AROP,text] }
DIVUH { [:AROP,text] }
NEG { [:AROP,text] }
CMP { [:AROP,text] }
ADC { [:AROP,text] }
SBB { [:AROP,text] }
HLT { [:HLT,text] }
\w+ { [:IDENT,text] }
inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
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
end
