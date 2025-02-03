extends Resource

class_name GUIViewConfig

@export var id : StringName
@export var prefab : PackedScene

signal new_noti

var notification_count : int = 0:
	set(value):
		notification_count = value
		emit_signal("new_noti")
