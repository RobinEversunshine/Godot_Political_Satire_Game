extends Control

@onready var contact_name = $PanelContainer/HBoxContainer/VBoxContainer/ContactName
@onready var contact_number = $PanelContainer/HBoxContainer/VBoxContainer/ContactNumber
@onready var contact_texture = $PanelContainer/HBoxContainer/ContactTexture
@onready var call_button = $PanelContainer/HBoxContainer/HBoxContainer/CallButton
@onready var message_button = $PanelContainer/HBoxContainer/HBoxContainer/MessageButton


@export var contact : Contact
@export var contact_name_mission : String
@export var contact_number_mission : String

func _ready():
	if contact != null:
		contact_name.text = contact.id
		contact_name.mission_name = contact_name_mission
		contact_number.text = str(contact.phone_number)
		contact_number.mission_name = contact_number_mission
		
		if contact.profile_photo_38 != null:
			contact_texture.texture = contact.profile_photo_38


func _on_call_button_pressed():
	if contact != null:
		PhoneText.dial_out(contact.phone_number)


func _on_message_button_pressed():
	Game.get_gui_view_manager().open_view("Chats")
	Game.get_up_scroll().noti_anim_end()
	Game.get_up_scroll().clear_notification("Chats")


func _on_call_button_mouse_entered():
	call_button.modulate.a = 0.7


func _on_call_button_mouse_exited():
	call_button.modulate.a = 1


func _on_message_button_mouse_entered():
	message_button.modulate.a = 0.7


func _on_message_button_mouse_exited():
	message_button.modulate.a = 1
