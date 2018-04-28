require './CK2SpecialEncode.rb'


#encoder2 = CK2SpecialEncode.new('./シフトJIS一覧（UTF-8）.utf8b.txt')

if ARGV.size < 1
  print "Usage: ruby #{$0} 'directory'\n"
  exit(1)
end

encoder = CK2SpecialEncode.new(ARGV[0])