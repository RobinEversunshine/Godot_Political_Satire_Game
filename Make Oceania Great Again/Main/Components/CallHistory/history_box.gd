extends Control

@export var in_icon : Texture2D
@export var out_icon : Texture2D
@export var missed_icon : Texture2D
@export var failed_icon : Texture2D

@export var phone_call : Call
@export var call_name_mission : String

@onready var texture_rect = $MarginContainer/HBoxContainer/TextureRect
@onready var call_name = $MarginContainer/HBoxContainer/VBoxContainer/CallName
@onready var call_time = $MarginContainer/HBoxContainer/VBoxContainer/CallTime
@onready var date_time = $MarginContainer/HBoxContainer/DateTime
@onready var button = $Button


signal button_pressed

var has_record : bool = false


func _ready():
	button.disabled = true
	if phone_call != null:
		call_name.text = phone_call.contact_name
		call_name.mission_name = call_name_mission
		
		if phone_call.call_state == "in" || phone_call.call_state == "out":
			if phone_call.text_message_list.size() != 0:
				has_record = true
				button.disabled = false
				call_name.set_script(null)
				call_name.mouse_filter = 2
				call_time.set_script(null)
				call_time.mouse_filter = 2
		
		if phone_call.call_state == "in":
			call_time.text = phone_call.talk_time
			texture_rect.texture = in_icon
		elif phone_call.call_state == "out":
			call_time.text = phone_call.talk_time
			texture_rect.texture = out_icon
		elif phone_call.call_state == "failed":
			call_time.text = "call failed"
			texture_rect.texture = failed_icon
		elif phone_call.call_state == "missed":
			call_time.text = "call missed"
			texture_rect.texture = missed_icon
		elif phone_call.call_state == "rejected":
			call_time.text = "call rejected"
			texture_rect.texture = missed_icon
		elif phone_call.call_state == "canceled":
			call_time.text = "canceled"
			texture_rect.texture = failed_icon
		
		var call_time_dict : Dictionary = phone_call.call_time
		var call_time_dict_baked : Dictionary = DateTime.get_time_baked(call_time_dict)
		var current_time_dict : Dictionary = DateTime.date_time
		
		var time_string : String = call_time_dict_baked["hour"] + ":" + call_time_dict_baked["minute"]
		var date_string : String = call_time_dict_baked["month"] + "-" + call_time_dict_baked["day"]
		
		var unix_time : int = Time.get_unix_time_from_datetime_dict(call_time_dict)
		var unix_time_now : int = DateTime.unix_time#Time.get_unix_time_from_datetime_dict(current_time_dict)
		var time_difference : int = unix_time_now - unix_time

		if time_difference < 0:
			date_time.text = "in the future"
		elif time_difference < 60:
			date_time.text = tr("just now")
		elif time_difference < 86400:
			date_time.text = time_string + " " + tr("today")
		elif time_difference < 172800:
			date_time.text = time_string + " " + tr("yesterday")
		elif time_difference < 691200:
			var day = current_time_dict["day"] - call_time_dict["day"]
			date_time.text = str(day) + " " + tr("days ago")
		else:
			date_time.text = date_string


func _on_button_pressed():
	if has_record:
		emit_signal("button_pressed", phone_call)


func _on_button_mouse_entered():
	if has_record:
		modulate.a = 0.7


func _on_button_mouse_exited():
	if has_record:
		modulate.a = 1
