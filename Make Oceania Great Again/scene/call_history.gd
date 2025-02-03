extends BaseGUIView

@onready var scroll_container = $HistoryPage/Content/ScrollContainer
@onready var v_box_container = $Recents/ScrollContainer/MarginContainer/VBoxContainer
@onready var history_page = $HistoryPage


@onready var animation_player = $AnimationPlayer


@export var history_box : PackedScene

var layer : int = 0


func _ready():
	clip_contents = true
	update_history()
	PhoneText.connect("call_ended", update_call)


func update_history():
	for call_history in PhoneText.call_history_array:
		var new_h_box = history_box.instantiate()
		new_h_box.phone_call = call_history
		v_box_container.add_child(new_h_box)
		v_box_container.move_child(new_h_box, 0)
		new_h_box.connect("button_pressed", button_pressed)


func update_call():
	var new_h_box = history_box.instantiate()
	new_h_box.phone_call = PhoneText.call_history_array[-1]
	v_box_container.add_child(new_h_box)
	v_box_container.move_child(new_h_box, 0)
	new_h_box.connect("button_pressed", button_pressed)


func back():
	if layer == 0:
		close_self()
	elif layer == 1:
		animation_player.play_backwards("into_history")
		layer = 0


func button_pressed(phone_call : Call):
	if phone_call != null:
		animation_player.play("into_history")
		layer = 1
		scroll_container.scroll_vertical = 0
		history_page.update_content(phone_call)


func _on_back_button_pressed():
	back()


