class C
rule
  program: func program {result=[val[0],val[1]].flatten} | func {result=[val[0]]}
  
  func: type IDENT LPAREN RPAREN block {result={:name=>val[1],:rtype=>val[0],:code=>val[4]}}
  
  block: LCURL lines RCURL {result=val[1]}
  
  lines: line lines {result=[val[0],val[1]].flatten} | line {result=[val[0]]}
  
  line: stmt SEMICOLON {result=val[0]}
      | stmtnosemi {result=val[0]}
      | ASM {result={:type=>:asmline,:line=>val[0].chop}}
      
  stmt: IDENT EQUAL expr {result={:type=>:set,:var=>val[0],:expr=>val[2],:line=>@lineno}}
      | postfixexp EQUAL expr {result={:type=>:arrayset,:getexpr=>val[0],:expr=>val[2]}}
      | type IDENT {result={:type=>:vardec,:var=>val[1],:typ=>val[0]}}
      | type IDENT EQUAL expr {result={:type=>:vardec,:var=>val[1],:typ=>val[0],:init=>val[3]}}
      | EXTERN type IDENT {result={:type=>:vardec,:var=>val[2],:typ=>val[1],:extern=>true}}
      | expr LPAREN RPAREN {result={:type=>:call,:addr=>val[0]}}
  
  optstmtsemi: stmt SEMICOLON {result=val[0]}
              | SEMICOLON {result=nil}
              
  optexprsemi: expr SEMICOLON {result=val[0]}
              | SEMICOLON {result=nil}
              
  optstmtparen: stmt RPAREN {result=val[0]}
              | RPAREN {result=nil}
              
  stmtnosemi: WHILE LPAREN expr RPAREN block {result={:type=>:while,:cond=>val[2],:code=>val[4]}}
            | FOR LPAREN optstmtsemi optexprsemi optstmtparen block {result={:type=>:for,:init=>val[2],:cond=>val[3],:post=>val[4],:code=>val[5]}}

  factor: NUM {result={:type=>:num,:val=>val[0]}}
        | IDENT {result={:type=>:var,:var=>val[0],:line=>@lineno}}
        | LPAREN expr RPAREN {result=val[1]}
        
  postfixexp: factor
            | postfixexp LBRACK expr RBRACK {result={:type=>:array,:off=>val[2],:base=>val[0]}}

  unaryexp: postfixexp
          | ASTERISK castexp {result={:type=>:deref,:addr=>val[1]}}
          | TILDE castexp {result={:type=>:inv,:val=>val[1]}}
  
  castexp: unaryexp
	       | LPAREN type RPAREN castexp {result={:type=>:cast,:typ=>val[1],:expr=>val[3]}}
          
  addexp: castexp
        | addexp PLUS castexp {result={:type=>:add,:v1=>val[0],:v2=>val[2]}}
        | addexp MINUS castexp {result={:type=>:sub,:v1=>val[0],:v2=>val[2]}}
  
  cmpexp: addexp
        | cmpexp GT addexp {result={:type=>:gt,:v1=>val[0],:v2=>val[2]}}
  
  bitor: cmpexp
       | bitor PIPE cmpexp {result={:type=>:bitor,:v1=>val[0],:v2=>val[2]}}
  expr: bitor
      
  type: TYPE {result={:type_type=>:scalar,:type=>val[0]}}
  | TYPE ASTERISK {result={:type_type=>:pointer,:type=>val[0]}}
end

---- inner
def initialize()
  @yydebug=true
  super
end
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
