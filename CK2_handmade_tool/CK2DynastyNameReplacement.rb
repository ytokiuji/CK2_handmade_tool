require './CK2FolderOrFileJudgment.rb'
require './CK2DynastyReplaceNameList.rb'
require 'pp'

#=CK2DynastyNameReplacement
# CK2のDynastyデータが記述されているテキストファイルを読み込んで、
# nameのところを置換する機能があるクラス
class CK2DynastyNameReplacement
  include CK2FolderOrFileJudgment

  def initialize(target)
    #pp target
    @file_name_time = Time.now.strftime("%Y%m%d%H%M%S")
		file_list = FolderJudgement(target[:target], [/\.txt$/])
		if file_list.is_a?(String) 
			puts "文字列が指定されました。終了します。"
			exit 
    end
    @name_list = CK2DynastyrReplaceNameList.new(target[:map])
    
    # pp @name_list.arr
    # pp @name_list.get_name_from_id(1)
    # pp @name_list.get_namejp_from_id(1)
    # pp @name_list.get_row_from_id(1)

    file_list.each{|file_path|
      run(file_path, file_path.gsub(/.txt$/, ".utf8b.txt"))
    }
    
  end

  #
  # 一つのファイルの処理
  #
  def run(file_path, output_path)
    pp "入力ファイル：#{file_path}"
    pp "出力ファイル：#{output_path}"
    open_file(file_path)
    open_output_file(output_path)
    load
  end

  #
  # Crusader Kings 2 Characters Text fileを開く
  # @return 
  def open_file(path_src)
    begin
      @f = open(path_src, "rb:CP1252")
    rescue => exc
      pp exc
    else
    end
  end

  #
  # Crusader Kings 2 Characters Text fileを開く
  # @return 
  def open_output_file(path_src)
    begin
      bom = "\uFEFF"
      @out = ::File.open(path_src, "w:UTF-8")
      @out << bom
    rescue => exc
      pp exc
    else
    end
  end

  # 一つのファイルを読み込んだ後の処理
  def load()
    
    dynasty_id_temp = nil # DynastyIDを一時保存
    
    @f.each do | line |
      jline = line.strip
	  
			case jline
			when /^$/
			when /^#/
			when /^\d+\s*=\s*\{/
        dynasty_id_temp = line.slice(/^\d+/)
				pp "dynasty_id_temp: #{dynasty_id_temp}"
			when /^\d+\s*=\s*/
        dynasty_id_temp = line.slice(/^\d+/)
				pp "dynasty_id_temp: #{dynasty_id_temp}"
			when /^name\s*=/
				# one_man_arr[2] = line.encode('UTF-8').match(/^name\s*=\s*\"*(([a-z]|\-|[A-Z]|\s|[¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+)\"*/).to_a[1]
				# # /^name\s*=\s*"([[\w-]+[:blank:]]*[\w-]*)"/
				# x,one_man_arr2["name"], one_man_arr2["name_comment"] = line.encode('UTF-8').split(/\s*=\s*|\#/)
        name_temp = jline.encode('UTF-8').sub(/name\s*=\s*/, '').slice(/([a-z]|\-|[A-Z]|\s|[¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+/)

        @name_list.get_row_from_id(dynasty_id_temp).each{|row|
          if row['name'] == name_temp then
            line = "\t" + jline.gsub(/\"([a-z]|\-|[A-Z]|\s|[¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+\"/, "\"#{row['name_jp']}\"") + "\n"
            break
          end
        }
			when /^culture/
			when /^religion\s*=/
			when /^used_for_random/
			when /^coat_of_arms/
				#pp line
				coa_flag = true
			when /^template/
			when /^layer/
				layer_flag = true
			when /^data\s*=/
				data_flag = true
			when /^\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s\d+\s*/
			when /^texture\s*/
			when /^texture_internal/
			when /^emblem/
			when /^color/
			when /^can_appear\s*=/
			when /^\{/
			when /^\}/
				if 	data_flag == true
					data_flag = false
				elsif layer_flag == true
					layer_flag = false
				elsif coa_flag == true
					coa_flag = false
        else
          dynasty_id_temp = nil
					# all_arr.push(one_man_arr)
					# one_man_arr = []
					# one_man_arr2.clear
				end
			else
				pp "どの条件にもマッチしない「#{line.encode('UTF-8')}」"
			end

      # if scope_level > 1 then
      #   @out << "\t" * (scope_level - 1)
      # end
      @out << line.encode('UTF-8')
      #pp line

    end
    @f.close
    @out.close
    puts "ファイルの読み込みおわり"
  end


end