$labelno=0
$free_regs=[]
$mapping={"__irasmtemp__"=>"r13"}
$types={}
BP="r14"
SP="r15"
def prefix_for(var)
  if $types[var]
    case $types[var]
    when 8
      return "B"
    when 16
      return "W"
    when 32
      return "DW"
    end
  else
    return ""
  end
end

def gen_label()
  label="label#{$labelno}"
  $labelno+=1
  return label
end

def push(reg)
  return "ARI r15,r15,8,SUB,0\nST #{reg},(#{SP})\n"
end

def pop(reg)
  return "LD #{reg},(#{SP})\nARI r15,r15,8,ADD,0\n"
end

def get_mapping(var)
  if $mapping[var]
    return $mapping[var]
  else
    return var
  end
end

def load_in_reg(*vars); end

def in_reg(var)
  if $mapping[var]
    return true
  else
    return false
  end
end

def extern_var(var)
  if $mapping[var]
    return false
  else
    return true
  end
end

def array_arg_maker(base,off)
  if in_reg(off) and in_reg(base)
    return "#{get_mapping(off)}(#{get_mapping(base)})"
  elsif in_reg(off) and !in_reg(base)
    return "#{get_mapping(off)}(#{base})"
  elsif !in_reg(off) and in_reg(base)
    return "#{off}(#{get_mapping(base)})"
  else
    return "#{off}(#{base})"
  end
end

def gen_expr(expr,dest)
  load_in_reg(dest)
  case expr[:type]
  when :add
    load_in_reg(expr[:v1],expr[:v2])
    return "AR#{prefix_for(dest)} #{get_mapping(dest)},#{get_mapping(expr[:v1])},#{get_mapping(expr[:v2])},ADD,0\n"
  when :sub
    load_in_reg(expr[:v1],expr[:v2])
    return "AR#{prefix_for(dest)} #{get_mapping(dest)},#{get_mapping(expr[:v1])},#{get_mapping(expr[:v2])},SUB,0\n"
  when :bitor
    load_in_reg(expr[:v1],expr[:v2])
    return "AR#{prefix_for(dest)} #{get_mapping(dest)},#{get_mapping(expr[:v1])},#{get_mapping(expr[:v2])},OR,0\n"
  when :inv
    load_in_reg(expr[:val])
    return "AR#{prefix_for(dest)} #{get_mapping(dest)},#{get_mapping(expr[:val])},r0,NOT,0\n"
  when :deref
    if in_reg(expr[:addr])
      return "LD#{prefix_for(dest)} #{get_mapping(dest)},(#{get_mapping(expr[:addr])})\n"
    else
      return "LD#{prefix_for(dest)} #{get_mapping(dest)},(#{expr[:addr]})\n"
    end
  when :array
    return "LD#{prefix_for(dest)} #{get_mapping(dest)},#{array_arg_maker(expr[:off],expr[:base])}\n"
  when :num
    return "LD#{prefix_for(dest)} #{get_mapping(dest)},#{expr[:val]}\n"
  when :var
    if in_reg(expr[:var])
      return "AR#{prefix_for(dest)} #{get_mapping(dest)},#{get_mapping(expr[:var])},r0,ADD,1\n"
    else
      return "LD#{prefix_for(dest)} #{get_mapping(dest)}, #{expr[:var]}\n"
    end
  end
end

def gen_stmt(stmt)
  case stmt[:type]
  when :set
    if extern_var(stmt[:var])
      code=gen_expr(stmt[:expr],"__irasmtemp__")
      return code+="ST#{prefix_for("__irasmtemp__")} #{$mapping["__irasmtemp__"]},(#{get_mapping(stmt[:var])})\n"
    else
      return gen_expr(stmt[:expr],stmt[:var])
    end
  when :arrayset
    code=gen_expr(stmt[:expr],"__irasmtemp__")
    return code+="ST#{prefix_for("__irasmtemp__")} #{$mapping["__irasmtemp__"]},#{array_arg_maker(stmt[:off],stmt[:base])}\n"
  when :type
    if $free_regs.length==0
      #TODO: Implement register spilling
      puts "Registers full, exiting"
      exit 1
    else
      reg=$free_regs.shift
      $mapping[stmt[:var]]="r#{reg}"
      $types[stmt[:var]]=stmt[:typ]
    end
    return ""
  when :asmline
    return stmt[:line]+"\n"
  when :while
    case stmt[:cond]
    when :gt0
      label=gen_label()
      code="#{label}:\n"
      for stmt in stmt[:code]
        line=gen_stmt(stmt)
        code+=line
      end
      code+="JNZ (#{label})\n"
      return code
    end
  when :for
    if stmt[:init]
      code=gen_stmt(stmt[:init])
    else
      code=""
    end
    condlabel=gen_label()
    endlabel=gen_label()
    code+="#{condlabel}:\n"
    case stmt[:cond]
    when :gt0
      code+="JZ #{endlabel}\n"
    end
    for stmt in stmt[:code]
      line=gen_stmt(stmt)
      code+=line
    end
    if stmt[:post]
      code+=gen_stmt(stmt[:init])
    end
    code+="#{endlabel}:\n"
    return code
  when :call
    code=""
    for var,reg in $mapping
      next if var=="__irasmtemp__"
      code+=push(reg)
    end
    code+="JST r13,(r0)\n"
    for var,reg in $mapping
      next if var=="__irasmtemp__"
      code+=pop(reg)
    end
    return code
  when :callpoint
    code=""
    for var,reg in $mapping
      next if var=="__irasmtemp__"
      code+=push(reg)
    end
    code+="LD r0,(#{stmt[:func]})\n"
    code+="JST r13,(#{stmt[:func]})\n"
    for var,reg in $mapping
      next if var=="__irasmtemp__"
      code+=pop(reg)
    end
    return code
  end
end

def generate(ast)
  $labelno=0
  $free_regs=[]
  $mapping={"__irasmtemp__"=>"r13"}
  $types={}
  13.times do |i|
    $free_regs.push i
  end
  for func in ast
    code+="#{func[:name]}:\n"
    code+=push(BP)
    code+="AR #{BP},#{SP},r0,ADD,1\n"
    stmts=func[:code]
    for stmt in stmts
      line=gen_stmt(stmt)
      if line==nil
        puts "Cannot generate code for #{stmt}. Exiting."
        exit 1
      end
      code+=line
    end
    code+="AR #{SP},#{BP},ADD,1\n"
    code+=pop(BP)
  end
  return code
end
