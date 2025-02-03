extends Control

@onready var settings = $Settings
@onready var phone = %Phone
@onready var animation_player = $"../Components/AnimationPlayer"


func _ready():
	hide()
	settings.hide()
	phone.hide()
	LevelTransition.black()
	await get_tree().create_timer(2.5).timeout
	await LevelTransition.fade_out()
	await get_tree().create_timer(1).timeout
	if Game.reset_enable:
		launch_game()
	else:
		SoundPlayer.stop_music()
		enable()
	#get_window().transparent = true


func launch_game():
	animation_player.play("show_phone")
	await get_tree().process_frame
	phone.show()
	Game.get_gui_view_manager().open_view("Home")
	if !Game.edit_mode:
		Game.get_gui_view_manager().open_view("Lock")
	if !Game.reset_enable:
		SoundPlayer.play_music("air")
	
	if !Game.edit_mode:
		await get_tree().create_timer(4.5).timeout
		Game.new_noti("CallHistory", "Phone", tr("You have {0} missed calls").format([3]))
		
		await get_tree().create_timer(10).timeout
		if Global.is_on_lock:
			PhoneText.receive_call(6665, "boss", "Locked")
			
			await PhoneText.call_ended
			await get_tree().create_timer(10).timeout
			if Global.is_on_lock:
				Key.emit_morse(str(str(Key.oct_to_bin(Key.key_list[1])).bin_to_int()))
				PhoneText.receive_text(1984, "call_tailor", "the_none_exist_year")
				
				await get_tree().create_timer(60).timeout
				if Global.is_on_lock:
					PhoneText.receive_call(6665, "boss", "havent_found_the_password")
	else:
		Game.get_up_scroll().show_down_buttons()


func load_game():
	animation_player.play("show_phone")
	await get_tree().process_frame
	phone.show()
	Game.get_gui_view_manager().open_view("Home")
	SoundPlayer.play_music("air")
	Game.load_game()


func enable():
	show()
	modulate = Color.TRANSPARENT
	await get_tree().create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_CUBIC).finished

func disable():
	await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_CUBIC).finished
	hide()


func _on_new_game_button_pressed():
	await disable()
	await get_tree().create_timer(1).timeout
	if !Game.save_exists() && !Game.edit_mode:
		LevelTransition.play_cg()
		await LevelTransition.cg_finished
		await get_tree().create_timer(1).timeout
	launch_game()


func _on_continue_button_pressed():
	await disable()
	await get_tree().create_timer(1).timeout
	load_game()


func _on_settings_button_toggled(toggled_on):
	settings.visible = toggled_on


func _on_quit_button_pressed():
	await disable()
	get_tree().quit()





