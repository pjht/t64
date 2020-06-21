require_relative "parser.rb"
require_relative "lexer.rb"
$vars={}
$type_to_len={"char"=>8,"short"=>16,"int"=>32,"long"=>64}
$immvals={}
$labelno=0
$errors=false

def gen_label()
  label="label#{$labelno}"
  $labelno+=1
  return label
end

def val_for(var)
  # puts "val for #{var}"
  # puts $immvals
  # puts $vars
  if $immvals[var]
    val=$immvals[var]
    $immvals[var]=nil
  else
    if !(var.match /c_temp/) and $vars[var]==nil
      puts "error: use of undeclared variable '#{var}'"
      $errors=true
    end
    val=var
  end
  return val
end

def is_num(val) 
  return val.is_a? Numeric || (val.match /^\d+$/)!=nil
end

def binop(dest,var1,op,var2)
  code=[]
  code+=gen_expr(var1,dest,true)
  code+=gen_expr(var2,"exprc_temp",true)
  var1=val_for(dest)
  var2=val_for("exprc_temp")
  # if is_num(var1) and is_num(var2)
  #   $immvals[dest]=eval("#{var1}#{op}#{var2}")
  # else
    code.push [dest,var1,op,var2]
  # end
  return code
end
  

def gen_expr(expr,dest,in_recurse=false)
  # puts "GEN EXPR #{expr}"
  code=[]
  case expr[:type]
  when :bitor
    code+=binop(dest,expr[:v1],"|",expr[:v2])
  when :gt
    code+=binop(dest,expr[:v1],">",expr[:v2])
  when :add
    code+=binop(dest,expr[:v1],"+",expr[:v2])
  when :sub
    code+=binop(dest,expr[:v1],"-",expr[:v2])
  when :num
    code.push [dest,expr[:val],"num"]
    # $immvals[dest]=expr[:val]
  when :var
    if $vars[expr[:var]]==nil and (expr[:var].match /c_temp/)==nil
      puts "error: use of undeclared variable '#{expr[:var]}' at line #{expr[:line]}"
      $errors=true
    end
    code.push [dest,expr[:var],"var"]
    # $immvals[dest]=expr[:var]
  when :deref
    code+=gen_expr(expr[:addr],"exprc_temp",true)
    # if $immvals["exprc_temp"]
      # if $immvals["exprc_temp"].is_a? String
      #   puts $vars
      #   puts $vars[$immvals["exprc_temp"]]
      #   if $vars[$immvals["exprc_temp"]][:type_type]!="pointer"
      #     puts "Warning! Dereferencing #{$vars[$immvals["exprc_temp"]][:type]} #{$immvals["exprc_temp"]}" 
      #   end
      # end
    #   $immvals[dest]="*#{val_for("exprc_temp")}"
    # else
    code.push [dest,"exprc_temp","*"]
    # end
  when :inv
    code+=gen_expr(expr[:val],"exprc_temp",true)
    code.push [dest,"exprc_temp","~"]
  when :array
    code+=gen_expr(expr[:base],"exprc_temp1",true)
    code+=gen_expr(expr[:off],"exprc_temp2",true)
    code.push [dest,"exprc_temp1","[]","exprc_temp2"]
  when :cast
    code=gen_expr(expr[:expr],dest,true)
    len=$type_to_len[expr[:typ][:type]]
    # if $immvals[dest]
    #   if $immvals[dest].match /^\d+$/
    #     case len
    #     when 8
    #       code.push "#{dest}=#{$immvals[dest]}&0xFF;\n"
    #     when 16
    #       code.push "#{dest}=#{$immvals[dest]}&0xFFFF;\n"
    #     when 32
    #       code.push "#{dest}=#{$immvals[dest]}&0xFFFFFFFF;\n"
    #     end
    #   else
    #     currlen=$type_to_len[$vars[$immvals[dest]][:type]]
    #     case len
    #     when 8
    #       code.push "#{dest}=#{dest}&0xFF;\n" if currlen>8
    #     when 16
    #       code.push "#{dest}=#{dest}&0xFFFF;\n" if currlen>16
    #     when 32
    #       code.push "#{dest}=#{dest}&0xFFFFFFFF;\n" if currlen>32
    #     end
    #   end
    #   $immvals[dest]=nil
    # else
      case expr[:typ][:type_type]
      when :scalar
        if $vars[dest]==nil
          currlen=64
        else
          currlen=$type_to_len[$vars[dest][:type]]
        end
        case len
        when 8
          code.push [dest,dest,"&","0xFF"] if currlen>8
        when 16
          code.push [dest,dest,"&","0xFFFF"] if currlen>16
        when 32
          code.push [dest,dest,"&","0xFFFFFFFF"] if currlen>32
        end
      # end
    end
  end 
  if !in_recurse
    code.push [nil,nil,"expr_done"]
    $used_exp_temps=false
  end
  # puts "DONE EXPR"
  return code
end

def gen_stmt(stmt)
  # puts "GEN STMT #{stmt}"
  code=[]
  case stmt[:type]
  when :vardec
    $vars[stmt[:var]]=stmt[:typ]
    type_stmt=stmt[:extern] ? "type_extern" : "type"
    case stmt[:typ][:type_type]
    when :scalar
      code.push [nil,stmt[:var],type_stmt,$type_to_len[stmt[:typ][:type]]]
    when :pointer
      code.push [nil,stmt[:var],type_stmt,64]
    end
    if stmt[:init]
      code+=gen_expr(stmt[:init],stmt[:var])
      # if $immvals[stmt[:var]]
      #   code.push "#{stmt[:var]}=#{val_for(stmt[:var])};\n"
      #   $immvals[stmt[:var]]=nil
      # end
    elsif !stmt[:extern]
      code.push [stmt[:var],stmt[:var],"^",stmt[:var]]
    end
  when :set
    if $vars[stmt[:var]]==nil and !stmt[:var].match /c_temp/
      puts "error: use of undeclared variable '#{stmt[:var]}' at line #{stmt[:line]}"
      $errors=true
    end
    code+=gen_expr(stmt[:expr],stmt[:var])
    # if $immvals[stmt[:var]]
    #   code.push "#{stmt[:var]}=#{val_for(stmt[:var])};\n"
    #   $immvals[stmt[:var]]=nil
    # end
  when :arrayset
    code+=gen_expr(stmt[:getexpr][:base],"c_temp1")
    code+=gen_expr(stmt[:getexpr][:off],"c_temp2")
    code+=gen_expr(stmt[:expr],"c_temp3")
    code.push ["c_temp1","c_temp2","[]=","c_temp3"]
  when :call
    code+=gen_expr(stmt[:addr],"c_temp1")
    code.push [nil,"c_temp1","*()"]
  when :while
    cond_label=gen_label()
    end_label=gen_label()
    code.push [nil,nil,"start_scope"]
    code.push [nil,cond_label,":"]
    if stmt[:cond]
      code+=gen_expr(stmt[:cond],"c_temp1")
      code.push [nil,c_temp1,"ifnot",end_label]
    end
    for stmt in stmt[:code]
      line=gen_stmt(stmt)
      if line==[]
        puts "Cannot generate code for #{stmt}. Skipping."
      else
        code.push line
      end
    end
    code.push [nil,cond_label,"goto"]
    code.push [nil,nil,"end_scope"]
  when :for
    cond_label=gen_label()
    end_label=gen_label()
    code.push [nil,nil,"start_scope"]
    if stmt[:init]
      code+=gen_stmt(stmt[:init])
    end
    code.push [nil,cond_label,":"]
    if stmt[:cond]
      code+=gen_expr(stmt[:cond],"c_temp1")
      code.push [nil,"c_temp1","ifnot",end_label]
    end
    for stmt in stmt[:code]
      line=gen_stmt(stmt)
      if line==nil
        puts "Cannot generate code for #{stmt}. Skipping."
      else
        code+=line
      end
    end
    if stmt[:post]
      code+=gen_stmt(stmt[:post])
    end
    code.push [nil,cond_label,"goto"]
    code.push [nil,end_label,":"]
    code.push [nil,nil,"end_scope"]
  end
  code.push [nil,nil,"stmt_done"]
  $used_c_temps=false
  # puts "DONE STMT"
  return code
end

def genir(code)
  parser=C.new()
  ast=parser.parse(code)
  irast=[]
  for func in ast
    code=[]
    stmts=func[:code]
    for stmt in stmts
      line=gen_stmt(stmt)
      if line==nil
        puts "Cannot generate code for #{stmt}. Skipping."
      else
        code+=line
      end
    end
    irast.push({:name=>func[:name],:code=>code})
  end
  return irast
end
