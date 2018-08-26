require 'pp'
require 'csv'

class CK2CharacterReplaceNameList
  def initialize(source)

    @arr = {} # CSV::Table
    
    if FileTest.file?(source) and File.extname(source).casecmp?('.csv')
      puts "次のCSVファイルを置換文字列として読み込みます：#{File.basename(source)}"
      open_csv_file(source)
    end
  end

  attr_accessor :arr

  def open_csv_file(source)
    begin
      @arr = CSV.read(source, {headers: true, encoding: "BOM|UTF-8"})
      #pp @arr[1]
    rescue => exception
      pp exception
      pp 'The character encoding of the specified CSV file is not UTF-8. Please convert in advance.'
      exit 1
    end
  end

  def get_name_from_id(id)
    names = []
    @arr.each{|one_char_data|
      if one_char_data['id'] == id.to_s then
        names << one_char_data['name']
      end
    }
    return names
  end

  def get_namejp_from_id(id)
    namejps = []
    @arr.each{|one_char_data|
      if one_char_data['id'] == id.to_s && one_char_data['name_jp'] != '?' then
        namejps << one_char_data['name_jp']
      end
    }
    return namejps
  end

  def get_date_from_id(id)
    dates = []
    @arr.each{|one_char_data|
      if one_char_data['id'] == id.to_s && one_char_data['name_jp'] != nil then
        dates << one_char_data['date']
      end
    }
    return dates
  end

  def get_row_from_id(id)
    rows = []
    @arr.each{|one_char_data|
      if one_char_data['id'] == id.to_s then
        rows << one_char_data
      end
    }
    return rows
  end

end