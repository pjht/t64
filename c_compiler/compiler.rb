require_relative "frontend/frontend.rb"
require_relative "middleend/middleend.rb"
# require_relative "backend/backend.rb"
require "YAML"

if ARGV.length > 0
  name = ARGV[0]
else
  print "Enter .c file name:"
  name=gets.chomp!
  name+=".c" unless name.include? ".c"
end

code=File.read(name)
ir=genir(code)
ir=optimize(ir)
for func in ir
  puts "#{func[:name]}() {"
  for stmt in func[:code]
    puts "  #{stmt}"
  end
  puts "}"
end
# asm=generate(ir)
# 
# outfile=File.open(name.gsub(".c",".asm"),"w")
# outfile.print asm
# outfile.close
