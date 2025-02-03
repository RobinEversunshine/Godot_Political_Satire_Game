extends Control


@export var contact : Contact
@onready var message_scroll = $MessageScroll
@onready var margin_container = message_scroll.get_child(0)
@onready var v_box_container = margin_container.get_child(0)

@onready var contact_name = $header/CenterContainer/ContactName

@export var message : PackedScene
@onready var dialogue_responses_menu = $MessageScroll/MarginContainer/VBoxContainer/DialogueResponsesMenu
@onready var time_label = $MessageScroll/MarginContainer/VBoxContainer/TimeLabel
@onready var bg_texture = $BGTexture
@onready var skip_mode_button = $Down/CenterContainer/SkipModeButton


var active_response_menu : DialogueResponsesMenu
var text_call : Call
var available : bool = false

var last_dialogue_line : DialogueLine


func _ready():
	skip_mode_button.button_pressed = PhoneText.skip_mode
	contact_name.text = contact.id
	contact.connect("text_start", new_text_start)
	PhoneText.connect("reset_skipmode", reset_skipmode)
	
	if contact.phone_number == 4885:
		bg_texture.show()
	else:
		bg_texture.hide()
	
	if contact.text_call_list.size() > 0:
		for new_call in contact.text_call_list:
			if new_call != null:
				text_call = new_call
				
				if !new_call.is_history_call:
					new_call_time(new_call.call_time)
				
				if !new_call.call_end:
					new_call.connect("dialogue_changed", add_new_message)
				
				for history_dialogue : DialogueLine in new_call.text_message_list:
					var current_index : int = new_call.text_message_list.find(history_dialogue)
					if current_index != 0:
						last_dialogue_line = new_call.text_message_list[current_index - 1]
					else:
						last_dialogue_line = null
					
					add_new_dialogue_label(history_dialogue)
					if history_dialogue.responses.size() > 0 && !new_call.call_end && new_call.text_message_list.find(history_dialogue) == new_call.text_message_list.size() - 1:
						add_response(history_dialogue)
	update_scroll_respond()


func new_text_start():
	var new_call : Call = contact.text_call_list[-1]
	text_call = new_call
	new_call_time(new_call.call_time)
	new_call.connect("dialogue_changed", add_new_message)


func update_scroll(scroll_time : float = 0.2):
	await get_tree().process_frame
	var scroll_max = margin_container.size.y - message_scroll.size.y
	
	if message_scroll.scroll_vertical > scroll_max - 50:
		get_tree().create_tween().tween_property(message_scroll, "scroll_vertical", scroll_max, scroll_time).set_trans(Tween.TRANS_CUBIC)


func update_scroll_respond(scroll_time : float = 0.2):
	await get_tree().process_frame
	var scroll_max = margin_container.size.y - message_scroll.size.y
	get_tree().create_tween().tween_property(message_scroll, "scroll_vertical", scroll_max, scroll_time).set_trans(Tween.TRANS_CUBIC)



func new_call_time(time_shown : Dictionary):
	var new_time = time_label.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
	var time_baked : Dictionary = DateTime.get_time_baked(time_shown)
	new_time.text = "[center]" + time_baked["month"] + "/" + str(time_baked["day"]) + "/" + str(time_baked["year"]) + " " + time_baked["hour"] + ":" + time_baked["minute"]
	v_box_container.add_child(new_time)
	new_time.show()


func new_system_dialogue(input_dialogue_line : DialogueLine):
	var new_system = time_label.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
	if !input_dialogue_line.text.begins_with("[color="):
		new_system.text = "[center]" + "[color=webgreen]" + input_dialogue_line.text
	else:
		new_system.text = "[center]" + input_dialogue_line.text
	v_box_container.add_child(new_system)
	new_system.show()
	update_scroll()


func add_new_dialogue_label(input_dialogue_line : DialogueLine):
	if input_dialogue_line.character == "System":
		new_system_dialogue(input_dialogue_line)
		return null
	else:
		if not input_dialogue_line.text.is_empty():
			var new_message = message.instantiate()
			v_box_container.add_child(new_message)
			
			var new_dialogue_label = new_message.dialogue_label
			new_dialogue_label.dialogue_line = input_dialogue_line
			
			#mission complete
			var mission_name : String = input_dialogue_line.get_tag_value("mission")
			if mission_name != "":
				new_message.update_mission(mission_name)
			
			#player check
			if input_dialogue_line.character == "Player":
				new_message.is_player(true)
			else:
				new_message.is_player(false)
			
			new_message.update_profile(contact.profile_photo_38)
			if last_dialogue_line != null && input_dialogue_line.character == last_dialogue_line.character:
				new_message.hide_profile()
			
			new_message.update_width()
			return new_message
		else:
			return null


func add_new_message(input_dialogue_line : DialogueLine):
	if text_call.text_message_list.size() > 1:
		last_dialogue_line = text_call.text_message_list[-2]
	else:
		last_dialogue_line = null
	
	var new_message = add_new_dialogue_label(input_dialogue_line)
	if new_message != null:
		var new_dialogue_label = new_message.dialogue_label
		if PhoneText.skip_mode:
			new_message.hide()
			await text_call.skip_show
			new_message.show()
			new_dialogue_label.type_out()
			new_dialogue_label.skip_typing()
			
			if !available:
				contact.notification_count += 1
				Game.phone_shake()
				SoundPlayer.play_sound(SoundPlayer.Vibrating)
			
		else:
			await get_tree().process_frame
			new_dialogue_label.connect("line_count_changed", update_scroll)
			update_scroll()
			
			if available:
				#dialogue type out
				new_dialogue_label.type_out()
				SoundPlayer.play_sound(SoundPlayer.Textscroll)
				await new_dialogue_label.finished_typing
				SoundPlayer.stop_sound(SoundPlayer.Textscroll)
			else:
				contact.notification_count += 1
				Game.phone_shake()
				SoundPlayer.play_sound(SoundPlayer.Vibrating)
	add_response(input_dialogue_line)


func add_response(input_dialogue_line : DialogueLine):
	if input_dialogue_line.responses.size() > 0:
		var new_responses_menu = dialogue_responses_menu.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
		new_responses_menu.set_responses(input_dialogue_line.responses)
		new_responses_menu.modulate = Color.TRANSPARENT
		active_response_menu = new_responses_menu
		
		if !PhoneText.skip_mode:
			await get_tree().create_timer(1).timeout
		
		v_box_container.add_child(new_responses_menu)
		get_tree().create_tween().tween_property(new_responses_menu, "modulate", Color.WHITE, 0.4).set_trans(Tween.TRANS_CUBIC)
		update_scroll_respond(0.4)
	
	if PhoneText.skip_mode:
		update_scroll_respond(0.4)


#click the chatbox to show chatpage
func set_able(able : bool):
	if able:
		move_to_front()
		available = true
	else:
		available = false


#player choose response
func _on_dialogue_responses_menu_response_selected(response):
	get_tree().create_tween().tween_property(active_response_menu, "modulate", Color.TRANSPARENT, 0.4).set_trans(Tween.TRANS_CUBIC)
	var scroll_target = margin_container.size.y - message_scroll.size.y - active_response_menu.size.y - 8
	await get_tree().create_tween().tween_property(message_scroll, "scroll_vertical", scroll_target, 0.4).set_trans(Tween.TRANS_CUBIC).finished
	active_response_menu.queue_free()
	await get_tree().create_timer(0.3).timeout
	text_call.next(response.next_id)


func _on_back_button_pressed():
	get_parent().get_parent().back()


func _on_skip_mode_button_toggled(toggled_on):
	PhoneText.skip_mode = toggled_on


func reset_skipmode(value : bool):
	skip_mode_button.button_pressed = value



