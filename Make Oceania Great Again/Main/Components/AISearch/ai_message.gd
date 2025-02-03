extends HBoxContainer

@onready var dialogue_label = $PanelContainer/VBoxContainer/DialogueLabel
@onready var trigger = $PanelContainer/Trigger
@onready var placeholder = $Placeholder


func is_title():
	move_child(placeholder, 0)


func update_mission(mission_name : String):
	trigger.mission_name = mission_name

