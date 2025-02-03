@tool
extends Control

@export var texture : Texture2D
@export var text : String = "app"
@export var open_gui : String

@onready var app_button = $Control/AppButton
@onready var app_name = $Control/AppName

@onready var noti_number = $NotiNumber
@onready var number = $NotiNumber/Number

var view_config : GUIViewConfig

func _ready():
	app_button.texture_normal = texture
	app_name.text = text
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


func _on_texture_button_pressed():
	Game.get_gui_view_manager().open_view(open_gui)
	Game.get_up_scroll().noti_anim_end()
	Game.get_up_scroll().clear_notification(open_gui)
