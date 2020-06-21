$used=[]
$set=[]

def deadcode_getinfo(stmt)
  # p stmt
  if stmt[2]=="[]="
    $used.push stmt[0] if !$used.include? stmt[0] and stmt[0]!=nil
  else
    $set.push stmt[0] if !$set.include? stmt[0] and stmt[0]!=nil
  end
  $used.push stmt[1] if !$used.include? stmt[1] and stmt[1]!=nil
  $used.push stmt[3] if !$used.include? stmt[3] and stmt[1]!=nil
end

def deadcode_stmt(stmt,unused)
  stmt=nil if unused.include? stmt[0] and stmt[2]!="[]="
  return stmt
end

def deadcode(ast)
  for func in ast
    for stmt in func[:code]
      deadcode_getinfo(stmt)
    end
    unused=[1]
    while unused!=[]
      $set=[]
      $used=[]
      for stmt in func[:code]
        deadcode_getinfo(stmt)
      end
      unused=$set-$used
      newcode=[]
      for stmt in func[:code]
        newcode.push deadcode_stmt(stmt,unused)
      end
      func[:code]=newcode.compact
    end
  end
  return ast
end
