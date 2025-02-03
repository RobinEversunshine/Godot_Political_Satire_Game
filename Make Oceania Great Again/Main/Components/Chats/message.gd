extends Control

@onready var dialogue_label = $HBoxContainer/PanelContainer/VBoxContainer/DialogueLabel
@onready var trigger = $HBoxContainer/PanelContainer/Trigger
@onready var texture_rect = $HBoxContainer/TextureRect
@onready var texture_rect_2 = $HBoxContainer/TextureRect2
@onready var panel_container = $HBoxContainer/PanelContainer


func update_width():
	dialogue_label.custom_minimum_size = Vector2(196, 15)
	await get_tree().process_frame
	if dialogue_label.get_line_count() == 1 && !"[b]" in dialogue_label.dialogue_line.text:
		dialogue_label.autowrap_mode = 0
		dialogue_label.custom_minimum_size.x = 0


func is_player(is_player_bool : bool):
	if is_player_bool:
		texture_rect.modulate.a = 0
		dialogue_label.add_theme_color_override("default_color", Color.WEB_GRAY)
	else:
		texture_rect_2.modulate.a = 0
		panel_container.set_h_size_flags(2)


func update_profile(profile_photo : Texture2D):
	if profile_photo != null:
		texture_rect.texture = profile_photo


func hide_profile():
	texture_rect.modulate.a = 0
	texture_rect_2.modulate.a = 0


func update_mission(mission_name : String):
	trigger.mission_name = mission_name



