extends Control

@onready var note_name = $header/CenterContainer/NoteName
@onready var color_picker = $Content/PanelContainer/ColorPicker
@onready var color_picker_viewer = $Content/PanelContainer/SubViewport/ColorPicker


func update_mode(title : String):
	note_name.text = title
	var shader_gradient = material.get_shader_parameter("Gradient").gradient.colors
	
	if title == "White Color":
		color_picker.color = shader_gradient[-1]
		color_picker_viewer.color = shader_gradient[-1]
	elif title == "Black Color":
		color_picker.color = shader_gradient[0]
		color_picker_viewer.color = shader_gradient[0]


func _on_color_picker_color_changed(color):
	color_picker_viewer.color = color
	if note_name.text == "White Color":
		Game.get_color().set_color_white(color, 0)
	elif note_name.text == "Black Color":
		Game.get_color().set_color_black(color, 0)
