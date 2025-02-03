extends Control

@onready var noti_number = $NotiNumber
@onready var number = $NotiNumber/Number

var open_gui : String = "Missions"
var view_config : GUIViewConfig


func _ready():
	noti_number.modulate.a = 0
	if open_gui in Game.get_gui_view_manager().viewConfigMap:
		view_config = Game.get_gui_view_manager()._get_view_config(open_gui)
		update_notification()
		view_config.connect("new_noti", update_notification)


func update_notification():
	var notification_number : int = view_config.notification_count
	if notification_number == 0:
		noti_number.modulate.a = 0
	elif notification_number < 10:
		noti_number.modulate.a = 1
		number.text = str(notification_number)
	else:
		noti_number.modulate.a = 1
		number.text = "•"


func _on_back_button_pressed():
	var view_path : Array = Game.get_gui_view_manager().active_view_path
	if view_path.size() > 1 && view_path[-1] != null:
		view_path[-1].back()


func _on_home_button_pressed():
	var view_path : Array = Game.get_gui_view_manager().active_view_path.duplicate()
	if view_path.size() > 1:
		for gui_view in view_path:
			if gui_view.config.id == "Home" || gui_view.config.id == "PhoneCall":
				continue
			if gui_view != null:
				gui_view.close_self()


func _on_missions_button_pressed():
	if Game.get_gui_view_manager().active_view_path[-1].config.id != "Missions":
		Game.get_gui_view_manager().open_view("Missions")
		Game.get_up_scroll().noti_anim_end()
		Game.get_up_scroll().clear_notification("Missions")
	else:
		_on_back_button_pressed()




