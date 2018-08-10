module CK2FolderOrFileJudgment
  def FolderJudgement(path, file_name_rex)
    files_list = []
    #p file_name_rex
    if FileTest.directory? path
      # ディレクトリ指定
      check_open_directory(path) # フォルダ内にファイルが存在するか確認する
      files_list = Dir.children(path)
      #files_list.delete_if {|file_name| file_name !~ /\.utf8b\.csv$/}
      unless file_name_rex == nil
        file_name_rex.each{|rex|
          files_list.delete_if {|file_name| file_name !~ rex}
        }
      end
      #puts "指定されたフォルダにあるファイルの一覧を表示します"
      file_path_list = []
      files_list.each{|file_name|
        #read_file_per_char("#{before_conversion_text}/#{file_name}") 
        #@utf16_array.clear
        #@after_conversion_text.clear
        
        #p file_name
        file_path_list << "#{path}/#{file_name}"
      }
      return file_path_list
    elsif FileTest.file? path
        # ファイル指定
        #check_open_file(before_conversion_text)
        #read_file_per_char(before_conversion_text)
        #p path
        files_list = [path]
    else
        # 文字列指定
        unless path.is_a?(String) then exit(1) end
        
        #input_text_string(before_conversion_text)
        #convert_utf16_escaped()
        #print_escaped_array()
        p "string :#{path}"
        return path
    end
  end
  
  # 開くディレクトリをチェックする
  def check_open_directory(directory_name)
    puts "ディレクトリをチェックします"
    puts "コマンドライン引数で指定された「#{directory_name}」はフォルダです"

    files_list = Dir.children(directory_name)
    if files_list.size < 1
        raise "指定されたフォルダにファイルがありません" 
        exit(1)
    end
  end

  module_function :FolderJudgement

end