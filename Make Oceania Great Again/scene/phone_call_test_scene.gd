extends BaseDialogueTestScene
#$PhoneCall/
@onready var contact_name_label = $PhoneCall/ContactProfile/VBoxContainer/Name
@onready var profile = $PhoneCall/ContactProfile/VBoxContainer/Profile

@onready var scroll_container = $PhoneCall/Dialogue/ScrollContainer
@onready var margin_container = scroll_container.get_child(0)
@onready var v_box_container = margin_container.get_child(0)

@onready var phone_call_timer = $PhoneCall/TimerContainer/PhoneCallTimer

@onready var dialogue_label = $PhoneCall/Dialogue/ScrollContainer/MarginContainer/VBoxContainer/DialogueLabel
@onready var dialogue_responses_menu = $PhoneCall/Dialogue/ScrollContainer/MarginContainer/VBoxContainer/DialogueResponsesMenu

@onready var anim_player = $PhoneCall/AnimationPlayer
@onready var reject_button = $PhoneCall/Buttons/RejectButton
@onready var answer_button = $PhoneCall/Buttons/AnswerButton
@onready var calling_state = $PhoneCall/CallingStateContainer/CallingState

var phone_call : Call
var contact : Contact
var music_playing : bool
var active_response_menu : DialogueResponsesMenu

var answer_call : bool = false
var is_calling : bool = false
var button_pressed : bool = false


func add_new_message(input_dialogue_line : DialogueLine):
	if not input_dialogue_line.text.is_empty():
		#add new dialogue label
		var new_dialogue_label = dialogue_label.duplicate(DUPLICATE_GROUPS | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
		
		if input_dialogue_line.character == "Player":
			input_dialogue_line.text = "[color=web_gray]" + input_dialogue_line.text + "[/color]"
		elif input_dialogue_line.character == "System":
			input_dialogue_line.text = "[color=webgreen]" + input_dialogue_line.text + "[/color]"
		input_dialogue_line.text = "[center]" + input_dialogue_line.text
		
		new_dialogue_label.dialogue_line = input_dialogue_line
		v_box_container.add_child(new_dialogue_label)
		
		if PhoneText.skip_mode:
			await phone_call.skip_show
			new_dialogue_label.show()
			new_dialogue_label.type_out()
			new_dialogue_label.skip_typing()
		else:
			await get_tree().process_frame
			new_dialogue_label.show()
			new_dialogue_label.connect("line_count_changed", update_scroll)
			update_scroll()
			
			#dialogue type out
			new_dialogue_label.type_out()
			SoundPlayer.play_sound(SoundPlayer.Textscroll)
			await new_dialogue_label.finished_typing
			SoundPlayer.stop_sound(SoundPlayer.Textscroll)
	
	#player response
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


func call_end():
	await get_tree().create_timer(1).timeout
	is_calling = false
	reject_button_disable(false)

	SoundPlayer.play_sound(SoundPlayer.Phoneoff)
	for audio : AudioStream in contact.call_default_bg_sfx:
		if audio != null:
			SoundPlayer.stop_sound(audio)


#player choose response
func _on_dialogue_responses_menu_response_selected(response):
	get_tree().create_tween().tween_property(active_response_menu, "modulate", Color.TRANSPARENT, 0.4).set_trans(Tween.TRANS_CUBIC)
	var scroll_target = margin_container.size.y - scroll_container.size.y - active_response_menu.size.y - 10
	await get_tree().create_tween().tween_property(scroll_container, "scroll_vertical", scroll_target, 0.4).set_trans(Tween.TRANS_CUBIC).finished
	active_response_menu.queue_free()
	await get_tree().create_timer(0.3).timeout
	phone_call.next(response.next_id)


func update_information():
	if phone_call != null:
		#if phone_call.contact_number in Game.get_contact_list().phoneNumberMap:
			#contact = Game.get_contact_list().phoneNumberMap[phone_call.contact_number]
		#else:
		contact = Contact.new()
		contact.id = phone_call.contact_name
		contact.phone_number = phone_call.contact_number
		
		contact_name_label.text = contact.id
		if contact.profile_photo_128 != null:
			profile.texture = contact.profile_photo_128
		
		if phone_call.call_state == "in":
			pass
			#SoundPlayer.play_sound(SoundPlayer.Ringing)
			#missed()
			#while !button_pressed:
				#Game.phone_shake(5, 1.6)
				#await get_tree().create_timer(2.85).timeout
		elif phone_call.call_state == "out":
			SoundPlayer.play_sound(SoundPlayer.Phoneout)
			anim_player.play("call_contact")
			anim_player.stop()
			
			await get_tree().create_timer(3).timeout
			if contact!= null && contact.callable:
				if !button_pressed:
					anim_player.play()
					call_succeeded()
			else:
				call_failed()


func missed():
	await get_tree().create_timer(10).timeout
	if !button_pressed:
		call_missed()


func _ready():
	music_playing = SoundPlayer.music_playing
	SoundPlayer.pause_music()
	PhoneText.skip_mode = false
	scroll_container.get_v_scroll_bar().use_parent_material = true
	
	phone_call = Call.new()
	phone_call.call_state = "in"
	phone_call.contact_name = "TestScene"
	phone_call.dialogue_label = PhoneText.add_dialogue_label()
	phone_call.title = title
	phone_call.dialogue_resource = resource
	update_information()


func open():
	PhoneText.is_calling = true
	modulate.a = 0
	get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_CUBIC)


func close():
	await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.3).set_trans(Tween.TRANS_CUBIC).finished
	PhoneText.is_calling = false
	PhoneText.new_call_history(phone_call)
	PhoneText.skip_mode = false
	PhoneText.emit_signal("call_ended")
	if music_playing:
		SoundPlayer.continue_music()


func back():
	pass


func update_scroll(scroll_time : float = 0.2):
	await get_tree().process_frame
	var scroll_max = margin_container.size.y - scroll_container.size.y
	
	if scroll_container.scroll_vertical > scroll_max - 50:
		get_tree().create_tween().tween_property(scroll_container, "scroll_vertical", scroll_max, scroll_time).set_trans(Tween.TRANS_CUBIC)


func update_scroll_respond(scroll_time : float = 0.2):
	await get_tree().process_frame
	var scroll_max = margin_container.size.y - scroll_container.size.y
	get_tree().create_tween().tween_property(scroll_container, "scroll_vertical", scroll_max, scroll_time).set_trans(Tween.TRANS_CUBIC)



func start_timer():
	var time : int = 0
	while is_calling:
		var second = DateTime.add_zero(time % 60)
		var minute = DateTime.add_zero(floor(float(time) / 60))
		phone_call_timer.text = minute + ":" + second
		await get_tree().create_timer(1).timeout
		time += 1


func call_succeeded():
	answer_call = true
	SoundPlayer.stop_sound(SoundPlayer.Phoneout)
	reject_button_disable(true)
	is_calling = true
	
	await get_tree().create_timer(1).timeout
	start_timer()
	phone_call.connect("dialogue_changed", add_new_message)
	phone_call.connect("call_ended", call_end)
	phone_call.start()
	
	for audio : AudioStream in contact.call_default_bg_sfx:
		if audio != null:
			SoundPlayer.play_sound(audio)


func call_failed():
	SoundPlayer.stop_sound(SoundPlayer.Phoneout)
	reject_button_disable(true)
	calling_state.text = "call failed"
	await get_tree().create_timer(1).timeout
	phone_call.call_state = "failed"
	get_tree().quit()
	#close_self()


func call_missed():
	if !button_pressed:
		#Game.phone_stop_shake()
		button_pressed = true
	SoundPlayer.stop_sound(SoundPlayer.Ringing)
	answer_button_disable(true)
	reject_button_disable(true)
	calling_state.text = "call missed"
	await get_tree().create_timer(1).timeout
	phone_call.call_state = "missed"
	
	get_tree().quit()
	#close_self()


func answer_button_disable(disable : bool):
	if disable:
		answer_button.disabled = true
		answer_button.modulate.a = 0.5
		answer_button.get_node("Label").modulate.a = 0.5
	else:
		answer_button.disabled = false
		answer_button.modulate.a = 1
		answer_button.get_node("Label").modulate.a = 1

func reject_button_disable(disable : bool):
	if disable:
		reject_button.disabled = true
		reject_button.modulate.a = 0.5
		reject_button.get_node("Label").modulate.a = 0.5
	else:
		reject_button.disabled = false
		reject_button.modulate.a = 1
		reject_button.get_node("Label").modulate.a = 1


func _on_answer_button_pressed():
	#Game.phone_stop_shake()
	button_pressed = true
	SoundPlayer.stop_sound(SoundPlayer.Ringing)
	anim_player.play("answer_call")
	answer_button_disable(true)
	call_succeeded()


func _on_reject_button_pressed():
	if !button_pressed:
		#Game.phone_stop_shake()
		button_pressed = true
	SoundPlayer.stop_sound(SoundPlayer.Ringing)
	SoundPlayer.stop_sound(SoundPlayer.Phoneout)
	SoundPlayer.stop_sound(SoundPlayer.Phoneoff)
	answer_button_disable(true)
	reject_button_disable(true)
	calling_state.text = "call end"
	await get_tree().create_timer(1).timeout
	phone_call.talk_time = phone_call_timer.text
	
	if !answer_call:
		if phone_call.call_state == "in":
			phone_call.call_state = "rejected"
		elif phone_call.call_state == "out":
			phone_call.call_state = "canceled"
	
	get_tree().quit()
	#close_self()


func _on_skip_mode_button_toggled(toggled_on):
	PhoneText.skip_mode = toggled_on
