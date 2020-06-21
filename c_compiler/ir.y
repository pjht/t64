class IR
rule
  program: func program {result=[val[0],val[1]].flatten} | func {result=[val[0]]}
  func: IDENT LPAREN RPAREN block {result={:name=>val[0],:code=>val[3]}}
  block: LCURL lines RCURL {result=val[1]}
  lines: line lines {result=[val[0],val[1]].flatten} | line {result=[val[0]]}
  line: stmt SEMICOLON {result=val[0]}
      | ASM {result={:type=>:asmline,:line=>val[0].chop}}
  stmt: IDENT EQUAL expr {result={:type=>:set,:var=>val[0],:expr=>val[2]}}
      | IDENT LBRACK IDENT RBRACK EQUAL expr {result={:type=>:arrayset,:off=>val[2],:base=>val[0],:expr=>val[5]}}
      | IDENT LBRACK NUM RBRACK EQUAL expr {result={:type=>:arrayset,:off=>val[2],:base=>val[0],:expr=>val[5]}}
      | TYPE IDENT NUM {result={:type=>:type,:var=>val[1],:typ=>val[2]}}
      | IDENT LPAREN RPAREN {result={:type=>:call,:func=>val[0]}}
      | ASTERISK IDENT LPAREN RPAREN {result={:type=>:callpoint,:func=>val[1]}}
  expr: ASTERISK IDENT {result={:type=>:deref,:addr=>val[1]}}
      | IDENT LBRACK IDENT RBRACK {result={:type=>:array,:off=>val[2],:base=>val[0]}}
      | IDENT LBRACK NUM RBRACK {result={:type=>:array,:off=>val[2],:base=>val[0]}}
      | NUM {result={:type=>:num,:val=>val[0]}}
      | IDENT {result={:type=>:var,:var=>val[0]}}
      | IDENT PLUS IDENT {result={:type=>:add,:v1=>val[0],:v2=>val[2]}}
      | IDENT MINUS IDENT {result={:type=>:sub,:v1=>val[0],:v2=>val[2]}}
      | IDENT PIPE IDENT {result={:type=>:bitor,:v1=>val[0],:v2=>val[3]}}
      | TILDE IDENT {result={:type=>:inv,:val=>val[1]}}
      
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
  for index in @bytes.each_index.select {|index| @bytes[index]==label}
    @bytes[index,8]=make_bytes(@labels[label])
  end
end
