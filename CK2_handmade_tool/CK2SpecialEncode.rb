require 'nkf'

class CK2SpecialEncode

    @@low_escape_exception = {
        '0x80' => 0x20AC, 
        '0x82' => 0x201A,
        '0x83' => 0x0192,
        '0x84' => 0x201E,
        '0x85' => 0x2026,
        '0x86' => 0x2020,
        '0x87' => 0x2021,
        '0x88' => 0x02C6,
        '0x89' => 0x2030,
        '0x8A' => 0x0160,
        '0x8B' => 0x2039,
        '0x8C' => 0x0152,
        '0x8E' => 0x017D,
        '0x91' => 0x2018,
        '0x92' => 0x2019,
        '0x93' => 0x201C,
        '0x94' => 0x201D,
        '0x95' => 0x2022,
        '0x96' => 0x2013,
        '0x97' => 0x2014,
        '0x98' => 0x02DC,
        '0x99' => 0x2122,
        '0x9A' => 0x0161,
        '0x9B' => 0x203A,
        '0x9C' => 0x0153,
        '0x9E' => 0x017E,
        '0x9F' => 0x0178
    }

    def initialize(before_conversion_text)
        @utf16_array = Array.new() 
        @after_conversion_text = Array.new() 

        if FileTest.directory? before_conversion_text
            # ディレクトリ指定
            check_open_directory(before_conversion_text)
            files_list = Dir.children(before_conversion_text)
            files_list.delete_if {|file_name| file_name !~ /\.utf8b\.csv$/}
            files_list.each{|file_name|
                read_file_per_char("#{before_conversion_text}/#{file_name}") 
                @utf16_array.clear
                @after_conversion_text.clear
            }

        elsif FileTest.file? before_conversion_text
            # ファイル指定
            check_open_file(before_conversion_text)
            read_file_per_char(before_conversion_text)

        else
            # 文字列指定
            unless before_conversion_text.is_a?(String) then exit(1) end
            
            input_text_string(before_conversion_text)
            convert_utf16_escaped()
            print_escaped_array()
        end
    end

    # 開くディレクトリをチェックする
    def check_open_directory(directory_name)
        puts "ディレクトリをチェックします"
        p directory_name

        files_list = Dir.children(directory_name)
        if files_list.size < 1
            raise "指定されたフォルダにファイルがありません" 
            exit(1)
        end
    end

    #　開くファイルをチェックする
    def check_open_file(file_name)
        # ファイル名パターンの確認
        unless file_name =~ /utf8b\.csv$/
            raise "ファイル名を確認してください" 
            exit(1)
        end
    end

    # 参考：https://qiita.com/mogulla3/items/fbc2a46478872bebbc47
    # https://docs.ruby-lang.org/ja/latest/method/Kernel/m/open.html
    # ファイルから一文字ずつ読み込む
    def read_file_per_char(file_name)
        begin
            File.open(file_name, "rb:BOM|utf-8") do |file|
                file.each_char do |char|
                    push_utf16_array(char)
                end
            end
            convert_utf16_escaped()
            save_file_binary(file_name)

        rescue SystemCallError => exception
            puts %Q(class=[#{exception.class}] message=[#{exception.message}])
        rescue IOError => exception
          puts %Q(class=[#{exception.class}] message=[#{exception.message}])
          
        end
    end

    # 変換後の配列をバイナリファイルに出力する
    def save_file_binary(file_name)
        save_file_name = file_name.delete_suffix('.utf8b.csv')
        begin
          IO.binwrite("#{save_file_name}.csv", @after_conversion_text.pack("c*"))
        rescue SystemCallError => exception
          puts %Q(class=[#{exception.class}] message=[#{exception.message}])
        rescue IOError => exception
          puts %Q(class=[#{exception.class}] message=[#{exception.message}])
        end
    end

    # 文字列を受け取ったとき
    def input_text_string(before_conversion_text)
       before_conversion_text.split("").each{|char|
           push_utf16_array(char)
       }
    end

    # 受け取った1文字文の文字列をインスタンス変数配列に格納する
    def push_utf16_array(char)
        @utf16_array.push NKF.nkf('--ic=UTF-8-BOM --oc=UTF-16LE -m0 -x --no-best-fit-chars', char).unpack("S*")[0]
    end

    # UTF-16に変換した文字を格納したインスタンス変数配列をチェックして変換する
    def convert_utf16_escaped()
        high_byte_requirement = [0xA4,0xA3,0xA7,0x24,0x5B,0x00,0x5C,0x20,0x0D,0x0A,0x22,0x7B,0x7D,0x40,0x80,0x7E,0xBD]
        row_byte_requirement = [0xA4,0xA3,0xA7,0x24,0x5B,0x00,0x5C,0x20,0x0D,0x0A,0x22,0x7B,0x7D,0x40,0x80,0x7E,0xBD]

        @utf16_array.each{|char|
            begin
                escape_char = 0x10
                high = (char >> 8) & 0xFF
                low = char & 0xFF
                
                #p "変換前： #{sprintf("%#x", high)} #{sprintf("%#x", low)}"

                #1バイトのUTF-16
                if high==0 
                    @after_conversion_text.push low
                    next
                end

                # エスケープ判定開始
                escape_char += 
                case high
                when *high_byte_requirement then 2
                else  0
                end

                escape_char +=
                case low
                when *row_byte_requirement then 1
                else  0
                end
                
                #p "escape: #{sprintf("%#x", escape_char)}"

                case escape_char
                when 0x11
                    low += 15
                when 0x12
                    high -= high > 9 ? 9 : 0
                when 0x13
                    low += 15
                    high -= high > 9 ? 9 : 0
                when 0x10
                else
                end
                
                #p "es #{sprintf("%#x", high)} #{sprintf("%#x", low)}"
                #puts ""
                
                @after_conversion_text.push escape_char
                # 渡された下位バイトを見てエスケープ例外か判断して返す
                new_h = @@low_escape_exception[low] ? @@low_escape_exception[low] : low
                new_r = @@low_escape_exception[high] ? @@low_escape_exception[high] : high
                
                @after_conversion_text.push  new_h
                @after_conversion_text.push  new_r
                
                #p "変換後： #{sprintf("%#x", escape_char)} #{sprintf("%#x", new_h)} #{sprintf("%#x", new_r)}"
            rescue => exception
                pp exception
                puts "char: #{char}"
                exit 1
            end
        }
        #p "#{@utf8_array}"
    end

    # エスケープしたあとの配列を整形して表示
    def print_escaped_array()
        p @after_conversion_text
    end
end