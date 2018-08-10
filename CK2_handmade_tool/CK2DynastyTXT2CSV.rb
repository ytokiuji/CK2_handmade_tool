# -*- mode:ruby; coding:utf-8 -*-

require 'csv'
require 'date'
require 'pp'
require './CK2FolderOrFileJudgment.rb'
require './CK2DynastyTXTChoice.rb'

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
		save(y, path_dst, "w:utf-8")
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
		data_flag = false
		one_person_flag = false
		name_flag = false
		scope_level = 0
    all_arr.push(["id","id_comment","name","name_comment","culture","culture_comment","used_for_random","used_for_random_comment","texture","texture_internal","file_name"])
		f = open(path, "rb:CP1252")
		f.each do | line |
			#pp line
			#pp line.chop!
			#line.force_encoding('UTF-8')
			#line.scrub!('?')
			#line.scrub!("\s")
			#line.chomp!
			line.strip!
			#all_arr.push(line.split(/=|\#/))
			#pp line
			one_man_arr[10] = File.basename(path)
			
			report = CK2DynastyTXTChoice.new(line)
		
			#pp line
			#pp "coa_flag:#{coa_flag}"
			#pp "layer_flag:#{layer_flag}"
			#pp "data:#{data_flag}"
			#pp "Scope Level:#{scope_level}"
			
			case line
			when /\{.*\}/
			when /\{/
				scope_level += 1
				pp '+1'
			when /\}/
				scope_level -= 1
				pp '-1'
			else
			end

			case line
			when /^$/
			when /^#/
			when /^\d+\s*=\s*\{*/
				report.when_processing = SEPARATION_DYNASTY_ID
				#pp 'ID'
				one_man_arr[0] = report.output_line
				line2 = line.sub(/\s*=\s*\{*/, "")
				one_man_arr2["id"], one_man_arr2["id_comment"] = line2.split(/\#*/)
				one_person_flag = true
			when /^\d+\s=\s*/
				one_person_flag = true
			when /^\s*name\s*=/
				#pp 'name'
				report.when_processing = SEPARATION_DYNASTY_NAME
				one_man_arr[2] = report.output_line
				x,one_man_arr2["name"], one_man_arr2["name_comment"] = line.encode('UTF-8').split(/\s*=\s*|\#/)
				name_flag = true
			when /^\s*culture/
				#pp 'culture'
				report.when_processing = SEPARATION_DYNASTY_CULTURE
				one_man_arr[4] = report.output_line
				line2 = line.sub(" ", "")
				x,one_man_arr2["culture"],one_man_arr2["culture_comment"] = line2.split(/=|\#/)
				#pp line
			when /^\s*religion\s*=/
				#pp 'religion'
			when /^\s*used_for_random/
				report.when_processing = SEPARATION_DYNASTY_RANDOM
				one_man_arr[6] = report.output_line
				line2 = line.sub(" ", "")
				x,one_man_arr2["used_for_random"],one_man_arr2["used_for_random_comment"] = line2.split(/=|\#/)
				#pp line
			when /^\s*coat_of_arms/
				#pp line
				coa_flag = true
			when /\s*template/
				#x,one_man_arr[8],one_man_arr[9] = line.split(/=|\#/)
				#pp line
			when /\s*layer/
				layer_flag = true
			when /\s*data\s*=/
				#pp 'data'
				data_flag = true
			when /^\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s*/
			when /\s*texture\s*/
				one_man_arr2["texture"] = line.slice(/\d+/)
			when /\s*texture_internal/
				one_man_arr2["texture_internal"] = line.slice(/\d+/)
			when /\s*emblem/

			when /\s*color/
			when /\s*can_appear\s*=/
			when /\{/
			when /\}/
				if 	data_flag == true
					data_flag = false
				elsif layer_flag == true
					layer_flag = false
				elsif coa_flag == true
					coa_flag = false
				else
				
				end
			else
				pp "どの条件にもマッチしない「#{line.encode('UTF-8')}」"
			end

			if scope_level == 0 && name_flag then
				all_arr.push(one_man_arr)
				pp one_man_arr
				one_man_arr = []
				one_man_arr2.clear
				one_person_flag = false
				name_flag = false
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
		bom = "\uFEFF"
		fp = ::File.open(path, mode)
		fp << bom
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
