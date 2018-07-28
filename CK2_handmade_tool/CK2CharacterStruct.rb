$character = Struct.new("Character",
   :id,
   :name,
   :dynasty_id,
   :dynasty_name,
   :father_count,
   :father_id,
   :real_father,
   :father_name,
   :mother_id,
   :mother_name,
   :female,
   :martial,
   :diplomacy,
   :intrigue,
   :stewardship,
   :learning,
   :religion,
   :culture,
   :traits,			
   :add_claims,
   :birth,
   :death,
   :random_traits,
   :health,
   :fertility,
   :occluded,
   :dna,
   :name_count,
   :file,
   :dates)

class CK2CharacterStruct
    def initialize
        @char = $character.new(1,2,3,4,5,6,7,8,9,10)
    end
    
    def test
        @char.id
    end

end

    
   
#person構造体対CSV一次元配列添え字連想配列
$p_to_csv = {
  "id" => 0,
  "name" => 1,
  "dynasty_id" => 2,
  "father_id" => 3,
  "mother_id" => 4,
  "female" => 5,
  "martial" => 6,
  "diplomacy" => 7,
  "intrigue" => 8,
  "stewardship" => 9,
  "learning" => 10,
  "religion" => 11,
  "culture" => 12,
  "traits" => 16,			
  "add_claims" => 26,
  "birth" => 14,
  "death" => 15,
  "dates" => 36
}

 ##
 ## person構造体を受け取り、一レコードをCSVレコードに置き換える
 ##
 def personToCSVRec(person)

	# CSVファイルに渡す一次元配列
	csv_rec = Array.new(70)
	
	# 構造体メンバーごとの処理
	$p_to_csv.each do | key, value|
		
		# "traits" "add_claims" "dates"以外をcsv_recにコピーする
		case key
		when "traits"
		when "add_claims"
		when "dates"
		else
			#puts value
			#puts key
			#puts '=>'
			#puts person[key]
			#puts "\n\n"
			csv_rec[value.to_i] = person[key]
		end
		
	end
	return csv_rec
 end
 
# =begin
#	id	1
#	name	2
#	dynasty_id	3
#	father_id	4
#	mother_id	5
#	female	6
#	martial	7
#	intrigue	9
#	stewardship	10
#	learning	11
#	religion	12
#	culture	13
#	birth	14
#	death	15
#	trait1	16	
#	trait2	17
#	trait3	18
#	trait4	19
#	trait5	20
#	trait6	21
#	trait7	22
#	trait8	23
#	trait9	24
#	trait10	25
#	add_claim1	26
#	add_claim2	27
#	add_claim3	28
#	add_claim4	29
#	add_claim5	30
#	add_claim6	31
#	add_claim7	32
#	add_claim8	33
#	add_claim9	34
#	add_claim10	35
#	date1date	36
#	date1property	37
#	date1value	38
#	date2date	39
#	date2property	40
#	date2value	41
#	date3date	42
#	date3property	43
#	date3value	44
#	date4date	45
#	date4property	46
#	date4value	47
#	date5date	48
#	date5property	49
#	date5value	50
#	date6date	51
#	date6property	52
#	date6value	53
#	date7date	54
#	date7property	55
#	date7value	56
#	date8date	57
#	date8property	58
#	date8value	59
#	date9date	60
#	date9property	61
#	date9value	62
#	date10date	63
#	date10property	64
#	date10value	65
#	comment1	66
#=end