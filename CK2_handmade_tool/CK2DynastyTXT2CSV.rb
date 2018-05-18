# -*- mode:ruby; coding:utf-8 -*-

require 'csv'
require 'date'
require 'pp'
require './CK2FolderOrFileJudgment.rb'

#require './CK2DynastyStruct.rb'

# 
# Dynastyテキストファイルをコントロールするclass
#
class CK2DynastyTXT2CSV
	include CK2FolderOrFileJudgment
	attr_accessor :data
	@file_name_time
	
	def initialize(path)
		@file_name_time = Time.now.strftime("%Y%m%d%H%M%S")
		file_list = FolderJudgement(path, [/\.txt$/])
		if file_list.is_a?(String) 
			puts "文字列が指定されました。終了します。"
			exit 
		end
		file_list.each{|file_path|
			run(file_path, "#{file_path}.csv")
		}
	end
    
  def run(path_src, path_dst)
    x = load(path_src)
		y = transform(x)
		save(y, "all_dynasty.#{@file_name_time}.csv", 'a')
		save(y, path_dst, 'w')
  end
    
  def load(path)
		all_arr = []
		one_man_arr = []
		one_man_arr1 ={
			"id" => "",
			"id_comment" => "",
			"name" => "",
			"name_comment" => "",
			"culture" => "",
			"culture_comment" => "",
			"used_for_random" => "",
			"used_for_random_comment" => "",
			"texture" => "",
			"texture_internal" => "",
			"layer" => "",
			"color1" => "",
			"color2" => "",
			"color3" => "",
			"file_name" => ""
		}
		one_man_arr2 = one_man_arr1
		coa_flag = false
		layer_flag = false
    all_arr.push(["id","id_comment","name","name_comment","culture","culture_comment","used_for_random","used_for_random_comment","texture","texture_internal","file_name"])
		f = open(path)
		f.each do | line |
			#pp line
			#pp line.chop!
			line.force_encoding('UTF-8')
			line.scrub!('?')
			line.scrub!("\s")
			line.chomp!
			line.strip!
			#all_arr.push(line.split(/=|\#/))
			#pp line
			one_man_arr[10] = path
	  
			case line
			when /^\d+/
				line2 = line.sub(" = {", "")
				#one_man_arr[0],one_man_arr[1] = line2.split(/\#/)
				one_man_arr[0] = line.slice(/^\d+/)
				one_man_arr2["id"], one_man_arr2["id_comment"] = line2.split(/\#/)
				#pp line2
			when /^name\s*=/
				#x,one_man_arr[2],one_man_arr[3] = line.split(/=|\#/)
				one_man_arr[2] = line.match(/^name\s*=\s*"([[\w-]+[:blank:]]*[\w-]*)"/).to_a[1]
				x,one_man_arr2["name"], one_man_arr2["name_comment"] = line.split(/=|\#/)
			
			when /^culture/
				line2 = line.sub(" ", "")
				#x,one_man_arr[4],one_man_arr[5] = line2.split(/=|\#/)
				one_man_arr[4] = line.match(/^culture\s*=\s*"*([\w-]+)"*/).to_a[1]
				x,one_man_arr2["culture"],one_man_arr2["culture_comment"] = line2.split(/=|\#/)
				#pp line
			when /^used_for_random/
				line2 = line.sub(" ", "")
				x,one_man_arr[6],one_man_arr[7] = line2.split(/=|\#/)
				x,one_man_arr2["used_for_random"],one_man_arr2["used_for_random_comment"] = line2.split(/=|\#/)
				#pp line
			when /^coat_of_arms/
				#pp line
				coa_flag = true
			when /^template/
				#x,one_man_arr[8],one_man_arr[9] = line.split(/=|\#/)
				#pp line
			when /^layer/
				layer_flag = true
			when /^texture\s*/
				one_man_arr2["texture"] = line.slice(/\d+/)
			when /^texture_internal/
				one_man_arr2["texture_internal"] = line.slice(/\d+/)
			when /^emblem/

			when /^color/

			when /^}/
				if layer_flag == true
					layer_flag = false
				elsif coa_flag == true
					coa_flag = false
				elsif 
					all_arr.push(one_man_arr)
					one_man_arr = []
					one_man_arr2.clear
				end

			else
				#pp one_man_arr
			end

		end
			f.close
			all_arr
  end

  def transform(x)
    #x.map {|t| t.map {|s| s.gsub(/a/, 'b')}}
		x.each{ |row|
	  	i = 0
		  while i < 8
	    	row[i].to_s.strip!
				i = i + 1
	  	end
		}
	#pp x
  end

  def save(y, path, mode)
    fp = ::File.open(path, mode)
    y.each do |x|
      fp.write(x.join(",") + "\n")
    end
    fp.close
  end
end

#obj = TEXT_dy2CSV.new()
#arr = obj.load(ARGV[0])
#obj.transform(arr)
#obj.save(arr, ARGV[0]+".csv")
