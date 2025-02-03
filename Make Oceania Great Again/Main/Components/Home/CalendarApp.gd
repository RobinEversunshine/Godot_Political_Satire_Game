extends Control

@onready var month = $Month
@onready var day = $Day
@onready var events = $Events


const open_gui : String = "Calendar"


func _ready():
	var date_dict : Dictionary = DateTime.get_time_baked(DateTime.date_time)
	month.text = date_dict["month_name"]
	
	var day_string : String = str(DateTime.date_time["day"])
	if day_string.ends_with("1"):
		day_string += "st"
	elif day_string.ends_with("2"):
		day_string += "nd"
	elif day_string.ends_with("3"):
		day_string += "rd"
	else:
		day_string += "th"
	day.text = day_string



func _on_button_pressed():
	Game.get_gui_view_manager().open_view(open_gui)
	Game.get_up_scroll().noti_anim_end()
	Game.get_up_scroll().clear_notification(open_gui)
