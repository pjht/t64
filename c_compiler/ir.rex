class IR
macro
SPACE [\ ]+
rule
\/\/.+ {}
(\w+:)?[A-Z]+\s.+; { [:ASM,text]}
(\w+:).*; { [:ASM,text]}
0x[0-9a-f]+ { [:NUM, text.to_i(16)] }
\d+ { [:NUM, text.to_i] }
{SPACE} { }
\n { @line+=1 }
; { [:SEMICOLON,text] }
\( { [:LPAREN,text] }
\) { [:RPAREN,text] }
, { [:COMMA,text] }
: { [:COLON,text]}
= { [:EQUAL,text]}
\* { [:ASTERISK,text]}
\[ { [:LBRACK,text]}
\] { [:RBRACK,text]}
\{ { [:LCURL,text]}
\} { [:RCURL,text]}
\+ { [:PLUS,text]}
- { [:MINUS,text]}
\| { [:PIPE,text]}
~ { [:TILDE,text]}
>0 { [:GT0,text]}
type { [:TYPE,text]}
while { [:WHILE,text]}
for { [:FOR,text]}
\w+ { [:IDENT,text]}
. { [:UNK,text]}
inner
  def initialize()
    super
    @line=1
  end
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
