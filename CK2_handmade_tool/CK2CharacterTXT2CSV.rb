# -*- mode:ruby; coding:utf-8 -*-

require 'csv'
require 'date'
require 'pp'

require './CK2CharacterStruct.rb'
require './CK2FolderOrFileJudgment.rb'
require './CK2CharacterTXTChoice.rb'
require './CK2CharacterList.rb'

#pp ARGV[0]

# 
# キャラクターテキストファイルをコントロールするclass
#
class CK2CharacterTXT2CSV
	
	include CK2FolderOrFileJudgment

	def initialize(path)
		@file_name_time = Time.now.strftime("%Y%m%d%H%M")
		@characters = CK2CharacterList.new
		@one_file_characters = [@characters.get_character_column.keys]
		@all_files_characters = [@characters.get_character_column.keys]
		file_list = FolderJudgement(path, [/\.txt$/])
		if file_list.is_a?(String) 
			puts "文字列が指定されました。終了します。"
			exit
		end
		file_list.each{|file_path|
			run(file_path, "#{file_path}.csv")
		}
		save(@all_files_characters, "all_characters.#{@file_name_time}.csv", 'a')
	end
	
	def run(path_src, path_dst)
    # x = load(path_src)
		# y = transform(x)
		# save(y, "all_dynasty.#{@file_name_time}.csv", 'a')
		# save(y, path_dst, 'w')
		open_file(path_src)
		format_file(path_src)
		close_file()
		csv_save(path_dst)
  end
  
  # Crusader Kings 2 Characters Text fileを開く
  # @return 
  def open_file(path_src)
    begin
			@f = open(path_src, "rb:CP1252")
      #f.each {|line|
      #  pp line
      #}
      #f.close
    rescue => exc
      pp exc
    else
    end
  end
  
  # テキストファイルをcharacterクラスインスタンスに格納する
  def format_file(path_src)
    scope_level = 0
		date = nil
		name_count = 0
		father_count = 0
		char = $character.new()
		one_man_arr1 = []
	
	#テキストファイルを一行ずつ整形する
    @f.each {|line|
		line.strip!
		if line !~ /^name\s*=/
			line.gsub!("\s", '')
		end
	  
	  #一人分開始判断
	  if scope_level == 0
			char = $character.new()
			one_man_arr1 = @characters.get_character_column.clone
	  else
	    #pp char
	  end
	  
	  #p "CASE前=#{scope_level}"
		#pp line
		tong = CK2CharacterTXTChoice.new(line)
		
	  case line
	  when /^\n$/
	    #改行のみの行
	  when /^\#/
	  when /^\d+=\{/
			# キャラクターID
			tong.when_processing = SEPARATION_DYNASTY_ID
			one_man_arr1[:id] = char[:id] = tong.output_value
			scope_level += 1
	  when /^\d+\.\d+\.\d+=\{/
			# 年月日スコープ開始行
			tong.when_processing = SEPARATION_CHARACTER_DATE
			date = tong.output_value
			scope_level += 1
		when /^\s*effect\s*=\s*\{\s*c_\d+\s*=\s*\{\s*ROOT\s*=\s*\{\s*set_real_father\s*=/
			tong.when_processing = SEPARATION_CHARACTER_SET_REAL_FATHER_ID
			one_man_arr1[:real_father_id] = char[:real_father] = tong.output_value
	  when /effect={.+}/
	    # effect一行スコープ開始
	  when /light_infantry={\d+}/
	    # light_infantry一行スコープ
	  when /heavy_infantry={\d+}/
	    # light_infantry一行スコープ
	  when /pikemen={\d+}/
	    # pikemen一行スコープ
	  when /light_cavalry={\d+}/
	    # light_cavalry一行スコープ
	  when /archers={\d+}/
			# archers一行スコープ
		when /[ekdcb]_[\w-]+={make_primary_title=yes}/
		when /\{ROOT=\{capital=PREV\}\}/
			# タイトルコード1行スコープ
			#pp line
		when /add_character_modifier={modifier=greatest_of_khansduration=-*\d+}/
	  when /^effect={/
	    # effectスコープ開始
			scope_level += 1
	  when /^raise_levies={/
	    # raise_leviesスコープ開始
			scope_level += 1
	  when /^spawn_unit={/
	    #spawn_unitスコープ開始
			scope_level += 1
	  when /^troops={/
	    #troopsスコープ開始
			scope_level += 1
	  when /^ROOT={/
      scope_level += 1
	  when /^add_character_modifier={/
      scope_level += 1
	  when /^effect_even_if_dead={/
      scope_level += 1
	  when /^[ekdcb]_[\w-]+={/
			scope_level += 1
		when /opinion={/
			# opinionスコープ開始
			scope_level += 1
		when /holder_scope={/
			# holder_scopeスコープ開始
			scope_level += 1
		when /^dna=/
			tong.when_processing = SEPARATION_CHARACTER_DNA
			one_man_arr1[:dna] = char[:dna] = tong.output_value
		when /^disallow_random_traits=yes/
			one_man_arr1[:random_traits] = 'FALSE'
		when /^properties=/
			tong.when_processing = SEPARATION_CHARACTER_PROPERTIES
			one_man_arr1[:properties] = tong.output_value
	  when /^name\s*=\s*/
	    # 名前
			#pp line
			name_count += 1
			tong.when_processing = SEPARATION_CHARACTER_NAME
			one_man_arr1["name#{name_count}".intern] = char[:name] = tong.output_value
			if name_count > 1 then one_man_arr1["name#{name_count}_date".intern] = date end
	  when /^dynasty=/
			# dynasty id
			tong.when_processing = SEPARATION_CHARACTER_DYNASTY_ID
			one_man_arr1[:dynasty_id] = char[:dynasty_id] = tong.output_value
	  when /^father=/
			# father id
			father_count += 1
			tong.when_processing = SEPARATION_CHARACTER_FATHER_ID
			#one_man_arr1[:father_id] = char[:father_id] = tong.output_value
			one_man_arr1["father#{father_count}_id".intern] = char[:father_id] = tong.output_value
			if date != nil then 
				one_man_arr1["father#{father_count}_date".intern] = date 
			end
	  when /^mother=/
			# mother id
			tong.when_processing = SEPARATION_CHARACTER_ANY_ID
			one_man_arr1[:mother_id] = char[:mother_id] = tong.output_value
		when /^female=yes/
			tong.when_processing = SEPARATION_CHARACTER_FEMALE
			one_man_arr1[:female] = char[:female] = tong.output_value
		when /^martial=/
			tong.when_processing = SEPARATION_CHARACTER_ANY_ID
			one_man_arr1[:martial] = char[:martial] = tong.output_value
		when /^diplomacy=/
			tong.when_processing = SEPARATION_CHARACTER_ANY_ID
			one_man_arr1[:diplomacy] = char[:diplomacy] = tong.output_value
		when /^intrigue=/
			tong.when_processing = SEPARATION_CHARACTER_ANY_ID
			one_man_arr1[:intrigue] = char[:intrigue] = tong.output_value
		when /^stewardship=/
			tong.when_processing = SEPARATION_CHARACTER_ANY_ID
			one_man_arr1[:stewardship] = char[:stewardship] = tong.output_value
		when /^learning=/
			tong.when_processing = SEPARATION_CHARACTER_ANY_ID
			one_man_arr1[:learning] = char[:learning] = tong.output_value
		when /^(add|remove)_trait=/
		when /^trait=/
		when /^random_traits=/
			tong.when_processing = SEPARATION_CHARACTER_RANDOM_TRAITS
			one_man_arr1[:random_traits] = char[:random_traits] = tong.output_value
		when /^religion=/
			tong.when_processing = SEPARATION_CHARACTER_RELIGION
			one_man_arr1[:religion] = char[:religion] = tong.output_value
		when /^culture=/
			tong.when_processing = SEPARATION_CHARACTER_CULTURE
			one_man_arr1[:culture] = char[:culture] = tong.output_value
	  when /^birth=/
	    unless date then raise 'dateに日付が代入されていません' end
			one_man_arr1[:birth] = char[:birth] = date
		when /^}$/
	    #pp scope_level
			scope_level -= 1
			if scope_level <= 1 then date = nil end
			#pp scope_level
	  when /^}\#.+$/
			scope_level -= 1
			if scope_level <= 1 then date = nil end
		when /^death={death_reason=death_offmap}/
			one_man_arr1[:death] = char[:death] = case_when_deathequal(date, scope_level, char)
			#date = nil
		when /^death={death_reason=death_in_china_historic}/
			one_man_arr1[:death] = char[:death] = case_when_deathequal(date, scope_level, char)
			#date = nil
	  when /^death={/
			# deathスコープ開始
			one_man_arr1[:death] = char[:death] = case_when_deathequal_startscope(date, scope_level, char)
			#date = nil
			scope_level += 1
	  when /^death=/
			one_man_arr1[:death] = char[:death] = case_when_deathequal(date, scope_level, char)
			#date = nil
		when /^killer\s*=\s*/
		when /^(add|remove)_spouse=/
		when /^add_matrilineal_spouse\s*=\s*/
		when /^add_betrothal/
		when /^effect={add_consort=\d+}/
		when /^add_consort\s*=\s*/
		when /^effect={add_friend=\d+}/
		when /^death_reason=\w+/
		when /^(add|remove)_claim=/
		when /^employer\s*=\s*/
		when /^remove_title\s*=\s*/
		when /^give_minor_title\s*=\s*/
		when /^add_friend\s*=\s*/
		when /^set_character_flag\s*=\s*/
		when /^(give|remove)_nickname/
		when /^give_job_title\s*=\s*/
		when /^modifier\s*=\s*/
		when /^(clr|set)_global_flag\s*=\s*/
		when /^\s*capital\s*=\s*PREV\s*$/
		when /^\s*add_alliance\s*=\s*\{\s*who\s*=\s*ROOT\s*years\s*=\s*\d+\}\s*$/
		when ''
		else
	    pp "どの条件にもマッチしない「" + line.encode('UTF-8') + "」"
		end
		# 一人分終了判定
		if scope_level == 0 and char[:id] != nil
			one_man_arr1[:name_count] = char[:name_count] = name_count
			one_man_arr1[:father_count] = char[:father_count] = father_count
			char[:file] = File.basename(path_src)
			one_man_arr1[:file] = File.basename(path_src)
			@characters << char
			@one_file_characters.push(one_man_arr1.values)
			@all_files_characters.push(one_man_arr1.values)
			#pp one_man_arr1
			one_man_arr1 = Hash.new([])
			father_count = name_count = 0
	  end
	}
  end
	
	def case_when_deathequal_startscope(date, scope_level, char)
		begin
			unless date then raise 'dateに日付が代入されていません' end
			if scope_level != 2 then raise 'scope_level is not 2' end
			return date
			#pp char
			#pp scope_level
		rescue => exc
  		#p exc
			#pp char
			#pp scope_level
			exit
	  end
	end

	def case_when_deathequal(date, scope_level, char)
		begin
			unless date then raise 'dateに日付が代入されていません' end
			if scope_level != 2 then raise 'scope_level is not 2' end
			return date
		rescue => exc
			p '/^death=/条件で例外が発生しました'
			p exc
			pp char
			pp scope_level
			exit
		end
	end

  # 開いたキャラクターテキストファイルを閉じる
  def close_file
    begin
			@f.close
			@one_file_characters.clear
		rescue => exc
	  	pp exc
		else
		end
  end
  
  # characters Array
  def characters
    @characters
  end
  
  def characters=(value)
    @characters = value
  end
	
	# 一つのファイルを一つのCSVに出力
	def csv_save(path_dst)
		pp path_dst

		CSV.open(path_dst, "w:utf-8") do | csv |
			

			title = Array.new
			
			@characters[0].each_pair{|member, value|
				title << member
			}
			
	 	  csv << title
			@characters.each{|row|
				arr = Array.new
				row.each_pair{|member, value|
					arr << value
			  }
				csv << arr
	  	}
		end
	end

	def save(y, path, mode)
	
	 bom = "\uFEFF"
	 fp = ::File.open(path, mode)
	 fp << bom
	 ##fp << y[0].keys.join(',') + "\n"
	 ##pp y[0].keys.join(',') + "\n"
	 y.each do |x|
		 fp.write(x.join(',') + "\n")
		 #pp x.values.join(',') + "\n"
	 end
	 fp.close
  end

end

#o = CK2CharacterTXT2CSV.new(ARGV[0])
#o.open_file
#o.format_file
#o.close_file
#o.csv_save