extends BaseGUIView

@onready var label = $MarginContainer/VBoxContainer/Label
@onready var label2 = $MarginContainer/VBoxContainer/Label2
@onready var grid_container = $CenterContainer/GridContainer

@export var plus_extra : int = 0
@export var minus_extra : int = 0
@export var multiply_extra : int = 1
@export var divide_extra : int = 1

var new_number : bool = true
var current_num : String = "0"
var num1 : String = ""
var num2 : String = ""
var sign_math : String = ""


func _ready():
	for button_node in grid_container.get_children():
		if button_node.name.length() == 1:
			button_node.connect("pressed", input_number)


func input_number():
	if "=" in label.text:
		_on_clear_pressed()
	if new_number:
		current_num = ""
		new_number = false
	if current_num.length() < 8:
		current_num += get_viewport().gui_get_focus_owner().name
		if current_num.length() == 4 && Key.find_key(current_num):
			current_num = str(Key.remove_key(float(current_num)))
	label2.text = String.num_scientific(float(current_num))


func calculate():
	var result : float
	if sign_math == "+":
		result = float(num1) + float(num2)
		var removed_result = Key.remove_key(result)
		if result != removed_result:
			result = removed_result
		else:
			result += plus_extra
	
	elif sign_math == "-":
		result = float(num1) - float(num2)
		var removed_result = Key.remove_key(result)
		if result != removed_result:
			result = removed_result
		else:
			result -= minus_extra
	
	elif sign_math == "×":
		result = float(num1) * float(num2)
		var removed_result = Key.remove_key(result)
		if result != removed_result:
			result = removed_result
		else:
			result *= multiply_extra
	
	elif sign_math == "÷":
		result = float(num1) / float(num2)
		var removed_result = Key.remove_key(result)
		if result != removed_result:
			result = removed_result
		else:
			result /= divide_extra
	
	else:
		result = float(current_num)
		
	return Key.remove_key(result)


func calculate_function(input_sign : String):
	new_number = true
	if num1 == "":
		num1 = current_num
	else:
		num2 = current_num
		var result = str(calculate())
		num1 = result
		current_num = result
		label2.text = result
		num2 = ""
	sign_math = input_sign
	label.text = String.num_scientific(float(num1)) + input_sign


func num_int64(base : int = 10):
	new_number = true
	label.text = ""
	label2.text = String.num_int64(int(current_num), base)


func _on_dot_pressed():
	if "=" in label.text:
		_on_clear_pressed()
	if new_number:
		current_num = "0"
		new_number = false
	if ! "." in current_num:
		current_num += "."
		label2.text = String.num_scientific(float(current_num))


func _on_plus_pressed():
	calculate_function("+")

func _on_minus_pressed():
	calculate_function("-")

func _on_multiply_pressed():
	calculate_function("×")

func _on_divide_pressed():
	calculate_function("÷")


func _on_equal_pressed():
	new_number = true
	if num2 == "":
		num2 = current_num
	var result = str(calculate())
	if num1 != "":
		label.text = String.num_scientific(float(num1)) + sign_math + String.num_scientific(float(num2)) + "="
	else:
		label.text = String.num_scientific(float(num2)) + "="
	
	label2.text = String.num_scientific(float(result))
	num1 = ""
	num2 = ""
	sign_math = ""
	current_num = result


func _on_clear_pressed():
	new_number = true
	current_num = "0"
	num1 = ""
	num2 = ""
	sign_math = ""
	label.text = ""
	label2.text = "0"


func _on_bin_pressed():
	num_int64(2)

func _on_oct_pressed():
	num_int64(8)

func _on_hex_pressed():
	num_int64(16)


