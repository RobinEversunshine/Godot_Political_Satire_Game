extends Control

@onready var palette_name = $VBoxContainer/HBoxContainer/PaletteName
@onready var color_picker_white = $VBoxContainer/WhiteColor/HBoxContainer/ColorPickerWhite
@onready var color_picker_black = $VBoxContainer/BlackColor/HBoxContainer/CenterContainer/ColorPickerBlack


func _ready():
	var shader_gradient = material.get_shader_parameter("Gradient").gradient.colors
	color_picker_black.color = shader_gradient[0]
	color_picker_white.color = shader_gradient[-1]


func update_color_tween():
	var current_gradient = Game.get_color().get_current_gradient().colors
	get_tree().create_tween().tween_property(
		color_picker_white, "color", current_gradient[-1], 0.5
		).set_trans(Tween.TRANS_CUBIC)
	get_tree().create_tween().tween_property(
		color_picker_black, "color", current_gradient[0], 0.5
		).set_trans(Tween.TRANS_CUBIC)


func _on_forward_button_pressed():
	Game.get_color().change_gradient("forward")
	update_color_tween()


func _on_backward_button_pressed():
	Game.get_color().change_gradient("backward")
	update_color_tween()


func _on_random_color_button_pressed():
	Game.get_color().random_color()
	update_color_tween()


func _on_color_picker_white_color_changed(color):
	Game.get_color().set_color_white(color, 0)


func _on_color_picker_black_color_changed(color):
	Game.get_color().set_color_black(color, 0)
