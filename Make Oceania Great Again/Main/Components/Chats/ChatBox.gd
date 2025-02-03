extends Control

@onready var contact_name = $MarginContainer/HBoxContainer/VBoxContainer/ContactName
@onready var last_message = $MarginContainer/HBoxContainer/VBoxContainer/LastMessage
@onready var contact_texture = $MarginContainer/HBoxContainer/ContactTexture
@onready var noti_number = $NotiNumber
@onready var number = $NotiNumber/Number

@export var contact : Contact

signal button_pressed


func _ready():
	contact_name.text = contact.id
	update_notification()
	contact.connect("new_noti", update_notification)
	contact.connect("text_start", new_text_start)
	
	if contact.profile_photo_38 != null:
		contact_texture.texture = contact.profile_photo_38

	if contact.text_call_list.size() == 0:
		hide()
		contact.connect("text_start", show)
	else:
		var last_call : Call = contact.text_call_list[-1]
		if last_call != null:
			var text_message_list_invert : Array = last_call.text_message_list.duplicate()
			text_message_list_invert.reverse()
			for history_dialogue : DialogueLine in text_message_list_invert:
				if update_newest_message(history_dialogue):
					break
				else:
					continue
			if !last_call.call_end:
				last_call.connect("dialogue_changed", update_newest_message)


func new_text_start():
	var last_call : Call = contact.text_call_list[-1]
	last_call.connect("dialogue_changed", update_newest_message)


func update_newest_message(dialogue_line : DialogueLine):
	if dialogue_line.character != "System":
		move_to_top()
		last_message.autowrap_mode = 3
		last_message.text = strip_bbcode(dialogue_line.text)
		if last_message.get_line_count() > 1:
			while last_message.get_line_count() > 1:
				last_message.text = last_message.text.left(-3)
			last_message.text = last_message.text + "..."
			last_message.autowrap_mode = 0
		return true
	else:
		return false


func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)


func move_to_top():
	get_parent().move_child(self, 0)


func update_notification():
	var notification_number : int = contact.notification_count
	if notification_number == 0:
		noti_number.modulate.a = 0
	elif notification_number < 10:
		noti_number.modulate.a = 1
		number.text = str(notification_number)
	else:
		noti_number.modulate.a = 1
		number.text = "•"


func _on_contacter_button_pressed():
	contact.notification_count = 0
	emit_signal("button_pressed", contact)


func _on_contacter_button_mouse_entered():
	modulate.a = 0.7


func _on_contacter_button_mouse_exited():
	modulate.a = 1
