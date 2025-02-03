extends Node

const key_list : Array = [3705, 21404, 100]

const key_dict : Dictionary = {
	3705 : 3700,
	21404 : 11132,
	100 : 77,
}

const morse_list : Dictionary = {
	"a" : "01",
	"b" : "1000",
	"c" : "1010",
	"d" : "100",
	"e" : "0",
	"f" : "0010",
	"g" : "110",
	"h" : "0000",
	"i" : "00",
	"j" : "0111",
	"k" : "101",
	"l" : "0100",
	"m" : "11",
	"n" : "10",
	"o" : "111",
	"p" : "0110",
	"q" : "1101",
	"r" : "010",
	"s" : "000",
	"t" : "1",
	"u" : "001",
	"v" : "0001",
	"w" : "011",
	"x" : "1001",
	"y" : "1011",
	"z" : "1100",
	"0" : "11111",
	"1" : "01111",
	"2" : "00111",
	"3" : "00011",
	"4" : "00001",
	"5" : "00000",
	"6" : "10000",
	"7" : "11000",
	"8" : "11100",
	"9" : "11110",
	" " : "2"
}


signal morse_short
signal morse_long


func translate():
	var key_dict_tr : Dictionary = {}
	for key in key_dict:
		key_dict_tr[oct_to_bin(key)] = oct_to_bin(key_dict[key])
	return key_dict_tr


func oct_to_bin(input_oct : int):
	var output_bin : String = ""
	for n in str(input_oct):
		var n_bin : String = String.num_int64(int(n), 2)
		if n_bin.length() == 1:
			n_bin = "00" + n_bin
		elif n_bin.length() == 2:
			n_bin = "0" + n_bin
		output_bin += n_bin
	return int(output_bin)


func remove_key(input_num : float):
	var found_key : bool = false
	var remove_result : float
	
	for key in translate():
		if str(str(key).bin_to_int()) in str(input_num):
			found_key = true
			remove_result =  float(str(input_num).replace(str(str(key).bin_to_int()), str(str(translate()[key]).bin_to_int())))
			break
	
	if found_key:
		return remove_result
	else:
		return input_num


func find_key(input_num : String):
	if int(String.num_int64(int(input_num), 2)) in translate():
		return true
	else:
		return false


func is_the_date(date: Calendar.DateLibrary):
	if find_key(str(date.year)) && int(String.num_int64(int(date.month), 2)) == 110 && int(String.num_int64(int(date.day), 2)) == 100:
		return true
	return false


func emit_morse(key : String):
	for letter in key.to_lower():
		if !letter in morse_list:
			letter = " "
		var letter_morse = morse_list[letter]
		for morse_signal in letter_morse:
			if morse_signal == "0":
				emit_signal("morse_short")
				#print("0")
				await get_tree().create_timer(0.3).timeout
			elif morse_signal == "1":
				emit_signal("morse_long")
				#print("1")
				await get_tree().create_timer(1).timeout
			else:
				await get_tree().create_timer(1.5).timeout
		await get_tree().create_timer(2).timeout


