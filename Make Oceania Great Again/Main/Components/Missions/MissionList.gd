extends Control


@onready var mission_header_name_label = $MissionHeader/PanelContainer/HBoxContainer/MissionHeaderName
@onready var complete_percent_label = $MissionHeader/PanelContainer/HBoxContainer/CompletePercent
@onready var panel_container = $MissionHeader/PanelContainer
@onready var button = $MissionHeader/Button

@onready var scroll_page = $ScrollPage
@onready var v_box_container = scroll_page.get_child(0)

@export var mission_list_id : String


func _ready():
	var mission_name_list : Array = Global.MissionList[mission_list_id]
	if Global.MissionName[mission_name_list[0]] == "disabled":
		hide()
		Global.connect("mission_active", activate)
	
	var denominator : int = mission_name_list.size()
	var numerator : int = 0
	
	for mission_box in get_children():
		if mission_box.is_in_group("MissionBox"):
			mission_box.reparent(v_box_container)
			if Global.MissionName[mission_box.mission_id] == "completed":
				numerator += 1
	
	mission_header_name_label.text = mission_list_id
	complete_percent_label.text = str(numerator) + "/" + str(denominator)
	
	#all submissions are completed
	if numerator == denominator:
		panel_container.theme_type_variation = "ReversePanelContainer"
		mission_header_name_label.add_theme_color_override("font_color", Color.WHITE)
		complete_percent_label.add_theme_color_override("font_color", Color.WHITE)
		scroll_up_down(false, 0)
		button.button_pressed = true
	else:
		await get_tree().process_frame
		await get_tree().process_frame
		scroll_up_down(true, 0)
		#button.button_pressed = true


func activate(title : String):
	if title == mission_list_id:
		show()


#used to open or close the mission list page.
func scroll_up_down(up_down : bool, tween_time : float = 0.3):
	if up_down:
		var down_dest : float = scroll_page.get_child(0).size.y + 3
		
		get_tree().create_tween().tween_property(scroll_page, "size", Vector2(296, down_dest), tween_time).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(scroll_page, "modulate", Color.WHITE, tween_time).set_trans(Tween.TRANS_CUBIC)
		var down_dest_self : float = get_child(0).size.y + down_dest
		get_tree().create_tween().tween_property(self, "custom_minimum_size", Vector2(296, down_dest_self), tween_time).set_trans(Tween.TRANS_CUBIC)
	else:
		get_tree().create_tween().tween_property(scroll_page, "size", Vector2(296, 0), tween_time).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(scroll_page, "modulate", Color.TRANSPARENT, tween_time).set_trans(Tween.TRANS_CUBIC)
		get_tree().create_tween().tween_property(self, "custom_minimum_size", Vector2(296, 34), tween_time).set_trans(Tween.TRANS_CUBIC)


#func _on_button_toggled(toggled_on):
	#scroll_up_down(toggled_on)


func _on_button_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			scroll_up_down(button.button_pressed)





