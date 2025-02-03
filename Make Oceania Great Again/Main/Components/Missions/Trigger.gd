extends Control
class_name Trigger

@export var mission_name : String

const MOUSE_CLICK = preload("res://Main/Components/Missions/mouse_click.tscn")
var mouse_pos : Vector2

func _ready():
	connect("gui_input", trigger)


func trigger(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_pos = event.position
		else:
			if (event.position - mouse_pos).length() < 1:
				var mouse_tf = MOUSE_CLICK.instantiate()
				add_child(mouse_tf)
				mouse_tf.update_tf(mission_name)

