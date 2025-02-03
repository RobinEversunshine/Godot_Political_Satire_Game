extends Control

@export var fill_texture : Texture2D
@export var empty_texture : Texture2D

@onready var keyboard = $KeyBoard
@onready var state = $CenterContainer/PasswordPanel/State
@onready var password_points = $CenterContainer/PasswordPanel/PasswordPoints/HBoxContainer
@onready var hint_label = $CenterContainer2/HintLabel
@onready var animation_player = $AnimationPlayer


var password : String = "666666":
	set(value):
		password = value
		password_size = value.length()
		add_points()


var password_size : int = 6
var failed_times : int = 0

signal right_password


func _ready():
	clip_contents = true
	hide()
	add_points()
	set_points("")
	keyboard.connect("number_changed", set_points)
	keyboard.connect("number_filled", password_filled)


func add_points():
	keyboard.update_password(password)
	
	var current_size : int = password_points.get_children().size() - password_size
	if current_size < 0:
		for i in abs(current_size):
			var point_node = password_points.get_child(0).duplicate()
			password_points.add_child(point_node)
	elif current_size > 0:
		for i in current_size:
			password_points.get_child(i).queue_free()


func set_points(current_number : String):
	for i in password_size:
		if i < current_number.length():
			password_points.get_child(i).texture = fill_texture
		else:
			password_points.get_child(i).texture = empty_texture


func password_filled(current_number : String):
	if current_number == password.to_lower():
		state.text = "Correct password."
		await get_tree().create_timer(0.5).timeout
		emit_signal("right_password")
		close()
	else:
		failed_times += 1
		if failed_times == 5:
			hint_label.show()
		state.text = "Wrong password."
		animation_player.play("wrong_password")
		await keyboard.wrong_password()
		await get_tree().create_timer(0.2).timeout
		state.text = "Enter the password."


#open, update password and reset for this page
func open(new_password : String, hint : String = ""):
	animation_player.play("open")
	state.text = "Enter the password."
	hint_label.hide()
	hint_label.text = hint
	failed_times = 0
	password = new_password


func close():
	animation_player.play_backwards("open")
	await animation_player.animation_finished
	keyboard.current_number = ""


func _on_cancel_button_pressed():
	close()
