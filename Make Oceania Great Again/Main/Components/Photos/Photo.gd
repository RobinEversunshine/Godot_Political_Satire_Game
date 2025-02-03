extends TextureButton

@export var photo_name : String
@export var taken_time : Dictionary = {"year" : 2083, "month" : 12, "day" : 31}
@export var location : String = "N/A"
@export var people : String = "N/A"
@export var description : String
@export var hide_photo : bool = false
@export var duplicate_amount : int = 0

@export var mission_name : String

const MOUSE_CLICK = preload("res://Main/Components/Missions/mouse_click.tscn")

func _ready():
	mouse_filter = 1
	connect("pressed", trigger)


func trigger():
	var mouse_tf = MOUSE_CLICK.instantiate()
	add_child(mouse_tf)
	mouse_tf.update_tf(mission_name)



