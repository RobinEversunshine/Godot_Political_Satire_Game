extends Control

@onready var history_content = $Content/ScrollContainer/MarginContainer/HistoryContent
@onready var call_name = $Content/PanelContainer/VBoxContainer/CallName
@onready var date_time = $Content/PanelContainer/VBoxContainer/DateTime
@onready var call_time = $Content/PanelContainer/VBoxContainer/CallTime


func update_content(phone_call : Call):
	history_content.text = ""
	call_name.text = tr("Contact Name:") + " " + tr(phone_call.contact_name)
	call_time.text = tr("Duration of Call:") + " " + phone_call.talk_time
	
	var call_time_dict : Dictionary = phone_call.call_time
	var call_time_dict_baked : Dictionary = DateTime.get_time_baked(call_time_dict)
	var time_string : String = call_time_dict_baked["hour"] + ":" + call_time_dict_baked["minute"]
	var date_string : String = call_time_dict_baked["year"] + "-" + call_time_dict_baked["month"] + "-" + call_time_dict_baked["day"]
	
	date_time.text = tr("Call Time:") + " " + date_string + " " + time_string
	
	for history_dialogue : DialogueLine in phone_call.text_message_list:
		if !history_dialogue.text.is_empty():
			history_content.text += history_dialogue.text
			history_content.text += '''

'''

