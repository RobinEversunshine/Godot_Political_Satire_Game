extends BaseGUIView

@export var number_grid : GridContainer
@export var number_contain : Label

var current_number : String:
	set(value):
		current_number = value
		number_contain.text = current_number
	get:
		return current_number


func _ready():
	current_number = ""
	for child in number_grid.get_children():
		if child is Button && child.name != "DeleteButton":
			child.connect("pressed", input_number)


func input_number():
	current_number += get_viewport().gui_get_focus_owner().name


func _on_delete_button_pressed():
	current_number = current_number.left(-1)


func _on_answer_button_pressed():
	if current_number != "":
		PhoneText.dial_out(int(current_number))
	current_number = ""

