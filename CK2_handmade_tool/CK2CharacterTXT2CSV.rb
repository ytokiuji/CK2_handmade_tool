# -*- mode:ruby; coding:utf-8 -*-

require 'csv'
require 'date'
require 'pp'

require './CK2CharacterStruct.rb'

#pp ARGV[0]

# 
# キャラクターテキストファイルをコントロールするclass
#
class CK2CharacterTXT2CSV
  def initialize(file_name)
    @file_name = file_name
	@characters = Array.new
  end
  
  # Crusader Kings 2 Characters Text fileを開く
  # @return 
  def open_file
    begin
      @f = open( @file_name )
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
  def format_file
    scope_level = 0
	date = nil
	char = $character.new()
	
	#テキストファイルを一行ずつ整形する
    @f.each {|line|
	  line.strip!
	  line.gsub!("\s", '')
	  
	  #一人分開始判断
	  if scope_level == 0
	    char = $character.new()
		char[:file] = @file_name
	  else
	    #pp char
	  end
	  
	  #pp line
	  
	  case line
	  when /^\n$/
	    #改行のみの行
	  when /^\#/
	  when /^\d+=\{/
	    # キャラクターID
		#pp line
		#pp scope_level
		scope_level += 1
		#pp scope_level
		char[:id] = line.slice(/\d+/).to_i
		
	  when /^\d+\.\d+\.\d+=\{/
	    # 年月日スコープ開始行
	    #pp scope_level
		scope_level += 1
		#pp scope_level
		date = line.slice(/^\d+\.\d+\.\d+/)
		#pp date
		
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
		
	  when /^[ekdcb]_\w+={/
	    scope_level += 1

	  when /^name=/
	    # 名前
		pp line
		char[:name] = line.sub(/name=/, '').slice(/([a-z]|\-|[A-Z])+/)
	  when /^dynasty=/
	    # dynasty id
		char[:dynasty_id] = line.slice(/\d+/).to_i
	  when /^father=/
	    # father id
		char[:father_id] = line.slice(/\d+/).to_i
	  when /^mother=/
	    # mother id
		char[:mother_id] = line.slice(/\d+/).to_i
		
	  when /^female=yes/
	    char[:female] = 'TRUE'
		
	  when /^martial=/
	    char[:martial] = line.slice(/\d+/).to_i
		
	  when /^diplomacy=/
	    char[:diplomacy] = line.slice(/\d+/).to_i  
		
	  when /^intrigue=/
	    char[:intrigue] = line.slice(/\d+/).to_i
		
	  when /^stewardship=/
	    char[:stewardship] = line.slice(/\d+/).to_i
		
	  when /^learning=/
	    char[:learning] = line.slice(/\d+/).to_i
		
	  when /^add_trait=/
	  
	  when /^random_traits=/
	    char[:random_traits] = line.sub(/random_traits=/, '').slice(/([a-z]|-|[A-Z])+/)
	  when /^real_father=/
	    char[:real_father] = line.sub(/real_father=/, '').slice(/([a-z]|-|[A-Z])+/)
		
	  when /^religion=/
	    char[:religion] = line.sub(/religion=/, '').slice(/([a-z]|-|[A-Z])+/)
		
	  when /^culture=/
	    char[:culture] = line.sub(/culture=/, '').slice(/([a-z]|-|_|[A-Z])+/)
		
	  when /^birth=/
	    unless date then raise 'dateに日付が代入されていません' end
	    char[:birth] = date
		date = nil
		#pp char
	  
	  when /^}$/
	    #pp scope_level
		scope_level -= 1
		#pp scope_level
		
	  when /^}\#.+$/
	    scope_level -= 1
		
	  when /^death={/
	    # deathスコープ開始
	    begin
			unless date then raise 'dateに日付が代入されていません' end
			if scope_level != 2 then raise 'scope_level is not 2' end
			char[:death] = date
			#pp char
			date = nil
			scope_level += 1
			#pp scope_level
		rescue => exc
  		    p exc
			pp char
			pp scope_level
			exit
	  end
	  
	  when /^death=/
		#pp char
	    begin
		  unless date then raise 'dateに日付が代入されていません' end
		  if scope_level != 2 then raise 'scope_level is not 2' end
		  char[:death] = date
		  #pp char
		  date = nil
		  #pp scope_level
		rescue => exc
		  p exc
		  pp char
		  pp scope_level
		  exit
		end
	  
	  
		
	  when /^add_spouse=/
	  
	  when /^effect={add_consort=\d+}/
	  
	  when /^effect={add_friend=\d+}/
	  
	  when /^death_reason=\w+/
		#pp char
	  
	  when /^add_claim=/
	  
	  when /^dna=/
	  
	  when /^disallow_random_traits=yes/
	  
	  when /^properties=/
	  
	  when ''
	  else
	    pp "どの条件にもマッチしない「" + line + "」"
	  end
	  if scope_level == 0 and char[:id] != nil
	    #pp char
		@characters << char
	  end
	}
  end
  
  def close_file
    begin
	  @f.close
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
  
  def csv_save
    CSV.open(ARGV[0] + ".csv", "wb") do | csv |
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
end

#o = CK2CharacterTXT2CSV.new(ARGV[0])
#o.open_file
#o.format_file
#o.close_file
#o.csv_save