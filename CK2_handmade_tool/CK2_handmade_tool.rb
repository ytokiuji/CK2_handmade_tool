require 'optparse'
require './CK2SpecialEncode.rb'
require './CK2DynastyTXT2CSV.rb'
require './CK2CharacterTXT2CSV.rb'

parser = OptionParser.new
params = {}

#parser.on('-i') { puts "-i" }
#parser.on('-o') { puts '-o' }

subparsers = Hash.new {|h,k|
  $stderr.puts "no such subcommand: #{k}"
  exit 1
}
subparsers['escape'] = OptionParser.new.on('-i VAL', '--input VAL') {|v| encoder = CK2SpecialEncode.new(v) }
subparsers['dynasty'] = OptionParser.new.on('-i VAL', '--input VAL') {|v| 
  reader = CK2DynastyTXT2CSV.new(v) 
  #temp_arr = reader.load(v)
  #reader.transform(temp_arr)
  #reader.save(temp_arr, "#{v}.csv")
}
subparsers['character'] = OptionParser.new.on('-i VAL', '--input VAL') {|v|
  #puts "character -i #{v}" 
  reader = CK2CharacterTXT2CSV.new(v)
#o.open_file
#o.format_file
#o.close_file
#o.csv_save
}

parser.order!(ARGV)
subparsers[ARGV.shift].parse!(ARGV) unless ARGV.empty?