extends PanelContainer

@onready var mission_name_label = $HBoxContainer/MissionName
@onready var complete_label = $HBoxContainer/Complete

@export var mission_id : String
@export var completed : bool = false


func _ready():
	mission_name_label.text = mission_id
	
	if Global.MissionName[mission_id] == "completed":
		completed = true
		mission_complete()
	
	if Global.MissionName[mission_id] == "failed":
		complete_label.text = "failed"


func mission_complete():
	theme_type_variation = "ReversePanelContainer"
	mission_name_label.add_theme_color_override("font_color", Color.WHITE)
	complete_label.text = "completed"
	complete_label.add_theme_color_override("font_color", Color.WHITE)

