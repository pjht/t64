$immvals={}

def constprop_stmt(stmt)
  if $immvals[stmt[0]] && stmt[2]=="[]="
    stmt[0]=$immvals[stmt[0]]
  end
  if $immvals[stmt[1]]
    stmt[1]=$immvals[stmt[1]]
  end
  if $immvals[stmt[3]]
    stmt[3]=$immvals[stmt[3]]
  end
  if stmt[2]=="num" || stmt[2]=="var"
    $immvals[stmt[0]]=stmt[1]
  end
  return stmt
end

def constprop(ast)
  for func in ast
    newcode=[]
    for stmt in func[:code]
      newcode.push constprop_stmt(stmt)
    end
    func[:code]=newcode
  end
  return ast
end
