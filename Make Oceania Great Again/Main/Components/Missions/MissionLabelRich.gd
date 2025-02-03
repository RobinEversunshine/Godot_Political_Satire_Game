extends RichTextLabel
#class_name MissionLabel

const MOUSE_CLICK = preload("res://Main/Components/Missions/mouse_click.tscn")
var mouse_pos : Vector2

@export var input_mission_name : String
@export var independent : bool = false
var mission_name : String

func _ready():
	mouse_filter = 1
	connect("gui_input", trigger)
	if independent:
		text = mission_define(text)
	else:
		mission_name = input_mission_name


func mission_define(input_string : String = ""):
	if input_string.begins_with("[mission="):
		var end_brace_position : int = input_string.find("]")
		mission_name = input_string.left(end_brace_position).right(-"[mission=".length())
		return input_string.right(-end_brace_position - 1)
	else:
		mission_name = input_mission_name
		return input_string



func trigger(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_pos = event.position
		else:
			if (event.position - mouse_pos).length() < 1:
				var mouse_tf = MOUSE_CLICK.instantiate()
				add_child(mouse_tf)
				mouse_tf.update_tf(mission_name)

