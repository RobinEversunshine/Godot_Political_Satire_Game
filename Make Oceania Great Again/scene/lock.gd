extends BaseGUIView

@export var number_grid : GridContainer
@export var password_points : Control
@export var label : Label
@export var fill_texture : Texture2D
@export var empty_texture : Texture2D
@export var password : String

@onready var animation_player = $AnimationPlayer

var point_nodes : Array
var typeable : bool = true

var current_number : String:
	set(value):
		current_number = value
		set_password_point()
	get:
		return current_number


func _ready():
	current_number = ""
	for child in number_grid.get_children():
		if child is Button && child.name != "DeleteButton":
			child.connect("pressed", input_number)
	
	point_nodes = password_points.get_children()
	set_password_point()


func input_number():
	if typeable:
		current_number += get_viewport().gui_get_focus_owner().name
	if current_number.length() >= 4:
		if current_number == password:
			label.text = "Correct password."
			Global.is_on_lock = false
			for child in number_grid.get_children():
				if child is Button:
					child.disabled = true
					child.modulate.a = 0.5
			await get_tree().create_timer(0.5).timeout
			Game.get_up_scroll().show_down_buttons()
			close_self()
		
		elif Key.find_key(current_number):
			label.text = "Correct password."
			await get_tree().create_timer(0.5).timeout
			get_tree().quit()
			
		else:
			label.text = "Wrong password."
			typeable = false
			animation_player.play("wrong_password")
			Game.phone_shake()
			SoundPlayer.play_sound(SoundPlayer.Vibrating)
			for point in point_nodes:
				await get_tree().create_timer(0.1).timeout
				current_number = current_number.left(current_number.length() - 1)
				
			typeable = true
			await get_tree().create_timer(0.2).timeout
			label.text = "Enter the password."


func set_password_point():
	for point in point_nodes:
		if point_nodes.find(point) < current_number.length():
			point.texture = fill_texture
		else:
			point.texture = empty_texture


func open():
	pass


func close():
	animation_player.play("close")
	await animation_player.animation_finished


func _on_delete_button_pressed():
		current_number = current_number.left(-1)
