require './CK2FolderOrFileJudgment.rb'
require './CK2CharacterReplaceNameList.rb'
require 'pp'

#=CK2CharacterNameReplacement
# CK2のキャラクターデータが記述されているテキストファイルを読み込んで、
# nameのところを置換する機能があるクラス
class CK2CharacterNameReplacement
  include CK2FolderOrFileJudgment

  def initialize(target)
    #pp target
    @file_name_time = Time.now.strftime("%Y%m%d%H%M%S")
		file_list = FolderJudgement(target[:target], [/\.txt$/])
		if file_list.is_a?(String) 
			puts "文字列が指定されました。終了します。"
			exit 
    end
    @name_list = CK2CharacterReplaceNameList.new(target[:map])
    file_list.each{|file_path|
      run(file_path, file_path.gsub(/.txt$/, ".utf8b.txt"))
    }
    #pp name_list.arr
    # pp name_list.get_name_from_id(101)
    # pp name_list.get_namejp_from_id(101)
    # pp name_list.get_date_from_id(101)
    # pp name_list.get_row_from_id(101)
  end

  #
  # 一つのファイルの処理
  #
  def run(file_path, output_path)
    pp file_path
    pp output_path
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

  def load()
    scope_level = 0
    char_id_temp = nil # キャラクターIDを一時保存
    date_temp = nil # 年月日スコープの年月日を一時保存
    @f.each do | line |
      jline = line.strip

      #pp "scope_level: #{scope_level}"
      #pp line

      if scope_level <= 1 then
        date_temp = nil
      elsif scope_level < 0
        pp "スコープレベルエラー：#{scope_level}"
        pp line
        exit 1
      else
        #pp char
      end

      case jline
      when /^\s*\n$/
        #改行のみの行
      when /^\#/
      when /^\d+\s*=\s*\{/
        # キャラクターID
        scope_level += 1
        char_id_temp = jline.slice(/\d+/).to_i
        # if char_id_temp == 131582 then 
        #   exit(1)
        # end

      when /^\d+\.\d+\.\d+\s*=\s*\{/
        # 年月日スコープ開始行
        scope_level += 1
        date_temp = jline.slice(/^\d+\.\d+\.\d+/)
      when /effect\s*=\s*{.+}/
        # effect一行スコープ開始
      when /light_infantry\s*=\s*{\d+}/
        # light_infantry一行スコープ
      when /heavy_infantry\s*=\s*{\d+}/
        # light_infantry一行スコープ
      when /pikemen\s*=\s*{\d+}/
        # pikemen一行スコープ
      when /light_cavalry\s*=\s*{\d+}/
        # light_cavalry一行スコープ
      when /archers\s*=\s*{\d+}/
        # archers一行スコープ
      when /[ekdcb]_[\w-]+\s*=\s*{\s*make_primary_title\s*=\s*yes\s*}/
      when /\{\s*ROOT\s*=\s*\{\s*capital\s*=\s*PREV\s*\}\s*\}/
        # タイトルコード1行スコープ
        #pp line
      when /add_character_modifier\s*=\s*{\s*modifier\s*=\s*greatest_of_khansduration\s*=\s*-*\d+\s*}/
      when /^effect\s*=\s*{/
        # effectスコープ開始
        scope_level += 1
      when /^raise_levies\s*=\s*{/
        # raise_leviesスコープ開始
        scope_level += 1
      when /^spawn_unit\s*=\s*{/
        #spawn_unitスコープ開始
        scope_level += 1
      when /^troops\s*=\s*{/
        #troopsスコープ開始
        scope_level += 1
      when /^ROOT\s*=\s*{/
        scope_level += 1
      when /^add_character_modifier\s*=\s*{/
        scope_level += 1
      when /^effect_even_if_dead\s*=\s*{/
        scope_level += 1
      when /^[ekdcb]_[\w-]+\s*=\s*{/
        scope_level += 1
      when /opinion\s*=\s*{/
        # opinionスコープ開始
        scope_level += 1
      when /holder_scope\s*=\s*{/
        # holder_scopeスコープ開始
        scope_level += 1
      when /^name\s*=\s*/
        # 名前
        name_temp = jline.encode('UTF-8').sub(/name\s*=\s*/, '').slice(/([a-z]|\-|[A-Z]|\s|[¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+/)
        #pp @name_list.get_row_from_id(char_id_temp)
        
        @name_list.get_row_from_id(char_id_temp).each{|row|
          if row['name'] == name_temp && row['date'] == date_temp then
            line = "\t" * (scope_level) + jline.gsub(/\"([a-z]|\-|[A-Z]|\s|[¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ])+\"/, "\"#{row['name_jp']}\"") + "\n"
            break
          end
        }

      when /^dynasty\s*=\s*/
        # dynasty id
      when /^father\s*=\s*/
        # father id
      when /^mother\s*=\s*/
        # mother id
      when /^female\s*=\s*yes/
      when /^martial\s*=\s*/
      when /^diplomacy\s*=\s*/
      when /^intrigue\s*=\s*/
      when /^stewardship\s*=/
      when /^learning\s*=/
      when /^add_trait\s*=/
      when /^remove_trait\s*=/
      when /^trait\s*=/
      when /^random_traits\s*=/
      when /^real_father\s*=/
      when /^religion\s*=/
      when /^culture\s*=/
      when /^birth\s*=/
      when /^\s*}$/
        scope_level -= 1
      when /^\s*}\s*\#.+$/
        scope_level -= 1
      when /^death\s*=\s*{\s*death_reason\s*=\s*death_offmap\s*}/
      when /^death\s*=\s*{\s*death_reason\s*=\s*death_in_china_historic\s*}/
      when /^death\s*=\s*{/
        # deathスコープ開始
        scope_level += 1
      when /^death\s*=\s*/
      when /killer\s*=\s*/
      when /^add_spouse\s*=\s*/
      when /^remove_spouse\s*=/
      when /add_matrilineal_spouse\s*=/
      when /^add_consort\s*=\s*/
      when /^\s*remove_consort\s*=\s*$/
      when /^add_betrothal\s*=/
      when /^effect\s*=\s*{\s*add_consort\s*=\s*\d+\s*}/
      when /^effect\s*=\s*{\s*add_friend\s*=\s*\d+\s*}/
      when /^death_reason\s*=\s*\w+/
      when /^add_claim\s*=\s*/
      when /^employer\s*=\s*/
      when /^give_nickname\s*=\s*/
      when /^dna\s*=\s*/
      when /^disallow_random_traits\s*=\s*yes/
      when /^properties\s*=\s*/
      when /\s*remove_title\s*=\s*/
      when /\s*give_minor_title\s*=/
      when /\s*add_friend\s*=\s*/
      when /\s*set_character_flag\s*=\s*/
      when /\s*remove_claim\s*=/
      when /\s*add_alliance\s*=/
      when /^\s*break_alliance\s*=\s*FROM$/
      when /\s*capital\s*=\s*PREV$/
      when /^\s*capital\s*=\s*\"[bcdke]_\w+\"$/
      when /\s*remove_consor\s*=/
      when /^\s*set_real_father\s*=\s*PREV$/
      when /^\s*set_global_flag\s*=\s*mongol_horde_united$/
      when /^set_special_character_title\s*=\s*GENGHIS_KHAN$/
      when /^set_global_flag\s*=\s*temujin_born$/
      when /^\s*remove_nickname\s*=\s*yes$/
      when /^\s*who\s*=\s*ROOT$/
      when ''
      else
        pp "どの条件にもマッチしない「#{line.encode('UTF-8')}」"
      end

      # if scope_level > 1 then
      #   @out << "\t" * (scope_level - 1)
      # end
      @out << line
      #pp line

    end
    @f.close
    @out.close
    puts "ファイルの読み込みおわり"
  end


end