$vers={}

def isvar(var)
  return !(var.is_a? Numeric)
end

def tossa_stmt(stmt)
  if stmt[2]=="type" || stmt[2]=="type_extern"
    $vers[stmt[1]]=0
    stmt[1]="#{stmt[1]}.0"
    return stmt
  end
  if stmt[1] and isvar(stmt[1])
    stmt[1]="#{stmt[1]}.#{$vers[stmt[1]]}"
  end
  if stmt[3] and isvar(stmt[3])
    stmt[3]="#{stmt[3]}.#{$vers[stmt[3]]}"
  end
  if stmt[2]=="[]="
    if stmt[0] and isvar(stmt[0])
      stmt[0]="#{stmt[0]}.#{$vers[stmt[0]]}"
    end
  else
    if stmt[0] and isvar(stmt[0])
      $vers[stmt[0]]=-1 if $vers[stmt[0]]==nil
      $vers[stmt[0]]+=1
      stmt[0]="#{stmt[0]}.#{$vers[stmt[0]]}"
    end
  end
  return stmt
end

def fromssa_stmt(stmt)
  if stmt[0] and isvar(stmt[0])
    stmt[0].match(/(.+)\.\d+/)
    stmt[0]=$1
  end
  if stmt[1] and isvar(stmt[1])
    stmt[1].match(/(.+)\.\d+/)
    stmt[1]=$1
  end
  if stmt[3] and isvar(stmt[3])
    stmt[3].match(/(.+)\.\d+/)
    stmt[3]=$1
  end
  return stmt
end

def tossa(ast)
  for func in ast
    newcode=[]
    for stmt in func[:code]
      newcode.push tossa_stmt(stmt)
    end
    func[:code]=newcode
  end
  return ast
end

def fromssa(ast)
  for func in ast
    newcode=[]
    for stmt in func[:code]
      newcode.push fromssa_stmt(stmt)
    end
    func[:code]=newcode
  end
  return ast
end
