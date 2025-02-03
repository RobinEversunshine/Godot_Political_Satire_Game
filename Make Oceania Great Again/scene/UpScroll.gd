extends Control

@export var scroll_page : Control
@export var current_time  : Label
@onready var current_time_big = $ScrollPage/CenterContainer/VBoxContainer/CurrentTimeBig
@onready var date = $ScrollPage/CenterContainer/VBoxContainer/Date
@onready var year = $ScrollPage/CenterContainer2/Year

@onready var notification_box = $NotificationContainer/NotificationBox
@onready var noti_owner = $NotificationContainer/NotificationBox/HBoxContainer/VBoxContainer/NotiOwner
@onready var noti_content = $NotificationContainer/NotificationBox/HBoxContainer/VBoxContainer/NotiContent
@onready var noti_texture = $NotificationContainer/NotificationBox/HBoxContainer/NotiTexture

@onready var scroll_container = $ScrollPage/ScrollContainer
@onready var margin_container = scroll_container.get_child(0)
@onready var v_box_container = margin_container.get_child(0)
@onready var placeholder = v_box_container.get_child(0)

@onready var down_buttons = $DownButtons
@onready var animation_player = $AnimationPlayer

var is_dragging : bool = false
var click_time : float
var click_pos_start : Vector2
const click_time_threshold : float = 0.2


func _ready():
	clip_contents = true
	down_buttons.get_child(1).hide()
	update_time()
	update_date()
	DateTime.connect("minute_changed", update_time)
	DateTime.connect("day_changed", update_date)
	PhoneText.connect("call_start", scroll_up_down)


func _process(delta):
	if is_dragging:
		click_time += delta
		if Input.is_action_pressed("click"):
			scroll_page.position.y = clamp(get_local_mouse_position().y - 540, -540, 0)


func update_time():
	var time_dict : Dictionary = DateTime.get_time_baked(DateTime.date_time)
	var globle_time : String = time_dict["hour"] + ":" + time_dict["minute"]
	current_time.text = globle_time
	current_time_big.text = globle_time


func update_date():
	var date_dict : Dictionary = DateTime.get_time_baked(DateTime.date_time)
	date.text = tr(date_dict["weekday"]) + ", " + tr(date_dict["month_name"]) + " " + date_dict["day"]
	year.text = "Year " + date_dict["year"]


func new_notification(app_jump : String, inform1 : String = "", inform2 : String = ""):
	await noti_anim_end()
	animation_player.play("notification")
	notification_box.app_jump_target = app_jump
	notification_box.update_information(inform1, inform2)
	
	var view_config : GUIViewConfig = Game.get_gui_view_manager()._get_view_config(app_jump)
	view_config.notification_count += 1
	
	var noti_box = notification_box.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
	v_box_container.add_child(noti_box)
	noti_box.app_jump_target = app_jump
	update_scroll(noti_box)


func noti_anim_end():
	if animation_player.is_playing() && animation_player.current_animation == "notification":
		animation_player.play("end")
		await animation_player.animation_finished


func clear_notification(app_name : String):
	var visible_child_height : float = 0
	for child in v_box_container.get_children():
		if child.name != "Placeholder":
			if child.app_jump_target == app_name:
				child.queue_free()
			else:
				visible_child_height += child.size.y + 4
	if visible_child_height < 360:
		placeholder.custom_minimum_size.y = 360 - visible_child_height


func update_scroll(new_element : Control):
	await get_tree().process_frame
	var scroll_max = margin_container.size.y - scroll_container.size.y
	await get_tree().create_tween().tween_property(scroll_container, "scroll_vertical", scroll_max, 0.2).set_trans(Tween.TRANS_CUBIC).finished
	if new_element != null:
		placeholder.custom_minimum_size.y -= new_element.size.y + 4


func scroll_up_down(up_down : String = "up", set_trans : bool = true):
	var destination_y : float
	if up_down == "up":
		destination_y = -540
	elif up_down == "down":
		destination_y = 0
	var tween_time : float = abs(scroll_page.position.y - destination_y) / 200 * 0.2 + 0.2
	if set_trans:
		get_tree().create_tween().tween_property(scroll_page, "position", Vector2(0, destination_y), tween_time).set_trans(Tween.TRANS_CUBIC)
	else:
		get_tree().create_tween().tween_property(scroll_page, "position", Vector2(0, destination_y), tween_time / 2)


func show_down_buttons():
	down_buttons.get_child(1).modulate.a = 0
	await get_tree().create_timer(0.3).timeout
	down_buttons.get_child(1).show()
	get_tree().create_tween().tween_property(down_buttons.get_child(1), "modulate", Color.WHITE, 0.3)


func _on_mouse_enter_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			click_pos_start = get_local_mouse_position()
		else:
			is_dragging = false
			var target : String = "up"
			var set_trans : bool = true
			
			if click_time > click_time_threshold:
				if scroll_page.position.y > -270:
					target = "down"
				else:
					target = "up"
			else:
				var relative = get_local_mouse_position() - click_pos_start
				if abs(relative.y) > 20 || relative.y == 0:
					if relative.y > 0:
						target = "down"
					else:
						target = "up"
					
					if relative.y != 0:
						set_trans = false
					
			scroll_up_down(target, set_trans)
			click_time = 0


func _on_notification_button_pressed():
	scroll_up_down("up")
	noti_anim_end()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "notification":
		animation_player.play("end")
	elif anim_name == "end":
		noti_content.text = ""


func _on_texture_rect_pressed():
	scroll_up_down("down")



