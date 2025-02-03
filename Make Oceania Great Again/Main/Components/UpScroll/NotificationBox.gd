extends PanelContainer

@export var default_texture : Texture2D
@export var notepad_texture : Texture2D
@export var missions_texture : Texture2D
@export var contacts_texture : Texture2D
@export var call_history_texture : Texture2D

@onready var noti_owner = $HBoxContainer/VBoxContainer/NotiOwner
@onready var noti_content = $HBoxContainer/VBoxContainer/NotiContent
@onready var noti_texture = $HBoxContainer/NotiTexture

@export var app_jump_target : String
@export var owner_name : String
@export var content : String


func _ready():
	if owner_name != "" && content != "":
		update_information(owner_name, content)


func update_information(inform1 : String, inform2 : String):
	if app_jump_target == "Chats":
		noti_owner.text = inform1
		noti_content.text = strip_bbcode(inform2)
		noti_texture.texture = default_texture
		for contact_number in Game.get_contact_list().phoneNumberMap:
			var contact : Contact = Game.get_contact_list().phoneNumberMap[contact_number]
			if contact.id == inform1 && contact.profile_photo_38 != null:
				noti_texture.texture = contact.profile_photo_38
				break
	
	elif app_jump_target == "Missions":
		if inform2 == "activate":
			noti_content.text = "New Mission"
		elif inform2 == "complete":
			noti_content.text = "mission complete"
		elif inform2 == "possible":
			noti_content.text = "possible to be true"
		noti_owner.text = inform1
		noti_texture.texture = missions_texture
	
	elif app_jump_target == "Notepad":
		noti_owner.text = "Notepad"
		noti_content.text = tr(inform1) + " " + tr("has been added to your notepad")
		noti_texture.texture = notepad_texture
	
	elif app_jump_target == "Contacts":
		noti_owner.text = "Contacts"
		noti_content.text = tr(inform1) + " " + tr("has been added to your contacts")
		noti_texture.texture = contacts_texture
	
	elif app_jump_target == "CallHistory":
		noti_owner.text = inform1
		noti_content.text = inform2
		noti_texture.texture = call_history_texture
	else:
		noti_owner.text = inform1
		noti_content.text = inform2
	
	if !Game.get_gui_view_manager().find_view("PhoneCall"):
		Game.phone_shake()
		SoundPlayer.play_sound(SoundPlayer.Doorbell)
		SoundPlayer.play_sound(SoundPlayer.Vibrating)
	
	if noti_content.get_line_count() > 2:
		while noti_content.get_line_count() > 2:
			noti_content.text = noti_content.text.left(-3)
		noti_content.text = noti_content.text + "..."



func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)


func _on_notification_button_pressed():
	if !Global.is_on_lock:
		if !Game.get_gui_view_manager().find_view(app_jump_target):
			Game.get_gui_view_manager().open_view(app_jump_target)
		Game.get_up_scroll().scroll_up_down()
		await get_tree().create_timer(0.4).timeout
		Game.get_up_scroll().clear_notification(app_jump_target)
