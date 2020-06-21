require_relative "parser.rb"
require_relative "lexer.rb"

if ARGV.length > 0
  name = ARGV[0]
else
  print "Enter .t64 file name:"
  name=gets.chomp!
  name+=".t64" unless name.include? ".t64"
end
$infile=File.read(name)

parser=T64.new()
code,labels,linestarts,lineends=parser.parse($infile)

$outfile=File.open(name.gsub(".t64",".hex"),"w")
# $outfile.puts "v2.0 raw"
i=0
outbytes=[]
code.each do |line|
  for byte in line
    outbytes.push byte
  end
  len=lineends[i]-linestarts[i]
  padding=len-line.length
  padding.times do
    outbytes.push 0
  end
  i+=1
end
groups=[]
group=[]
for byte in outbytes
  if group.length==8
    groups.push group.reverse
    group=[]
  end
  group.push byte
end
groups.push group if group.length>0

p groups
for group in groups
  for byte in group
    $outfile.print byte.to_s(16).rjust(2,"0")
  end
  $outfile.puts
end
$outfile.close


$listfile=File.open(name.gsub(".t64",".lst"),"w")
lines=$infile.split("\n")
linestarts.length.times do |i|
  start=linestarts[i]
  len=lineends[i]-start
  linebytes=code[i]
  line=lines[i]
  $listfile.print (start.to_s(16).rjust(4, "0") + ": ")
  if linebytes
    linebytes.each do |byte|
      $listfile.print (byte.to_s(16).rjust(2, "0") + " ")
    end
  end
  $listfile.print line + "\n"
end

$listfile.puts
$listfile.puts "Symbol table:"

for label,loc in labels
  $listfile.puts "#{label}: #{loc.to_s(16).rjust(8,"0")}"
end

$listfile.close
