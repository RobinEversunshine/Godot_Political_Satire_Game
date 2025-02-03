extends Control

@onready var v_box_container = $CenterContainer/VBoxContainer

var current_number : String:
	set(value):
		current_number = value
		emit_signal("number_changed", current_number)

var password_size : int = 4
var typeable : bool = true

signal number_changed
signal number_filled


func _ready():
	for center in v_box_container.get_children():
		for button_node in center.get_child(0).get_children():
			if button_node is Button && button_node.name.length() == 1:
				button_node.connect("pressed", input_char)


func input_char():
	if typeable:
		if current_number.length() < password_size:
			current_number += get_viewport().gui_get_focus_owner().name
			if current_number.length() == password_size:
				emit_signal("number_filled", current_number.to_lower())


func wrong_password():
	typeable = false
	for i in password_size:
		await get_tree().create_timer(0.4 / password_size).timeout
		current_number = current_number.left(-1)
	typeable = true


func update_password(password : String):
	password_size = password.length()
	var is_number : int = 0
	for i in password:
		if i in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
			is_number += 1
	
	if is_number == password.length():
		only_numbers()
	elif is_number == 0:
		only_characters()
	else:
		both()


func only_numbers():
	for center in v_box_container.get_children():
		for button_node in center.get_child(0).get_children():
			if button_node is Button && button_node.name.length() == 1:
				if button_node.name in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
					button_node.disabled = false
					button_node.modulate.a = 1
					button_node.modulate.v = 1
				else:
					button_node.disabled = true
					button_node.modulate.a = 0.3
					button_node.modulate.v = 0.9


func only_characters():
	for center in v_box_container.get_children():
		for button_node in center.get_child(0).get_children():
			if button_node is Button && button_node.name.length() == 1:
				if button_node.name in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]:
					button_node.disabled = true
					button_node.modulate.a = 0.3
					button_node.modulate.v = 0.9
				else:
					button_node.disabled = false
					button_node.modulate.a = 1
					button_node.modulate.v = 1


func both():
	for center in v_box_container.get_children():
		for button_node in center.get_child(0).get_children():
			if button_node is Button && button_node.name.length() == 1:
				button_node.disabled = false
				button_node.modulate.a = 1
				button_node.modulate.v = 1


func _on_delete_button_pressed():
	current_number = current_number.left(-1)


